import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/core/service/analystics_service.dart';
import 'package:lumina/core/service/echo_service.dart';
import 'package:lumina/core/service/security_service.dart';

import 'hybrid_ai_service.dart';

class AiService {
  final HybridAiService _hybridAi = HybridAiService();
  final SecurityService _security = SecurityService();
  final EchoService _echoService = EchoService();

  late final TemplateGenerativeModel _templateModel =
      FirebaseAI.googleAI().templateGenerativeModel();

  // ── 1. TAG A MEMORY (hybrid — on-device first) ─────────────
  // NO masking — runs on-device via HybridAiService.
  // Data never leaves the device on the on-device path.
  Future<Map<String, dynamic>> tagMemory({
    required String question,
    required String answer,
  }) async {
    final prompt = '''
You are a memory tagging engine. Your ONLY job is to analyze the journal entry below and return a JSON object.

STRICT RULES — you MUST follow all of these:
- Return ONLY valid JSON. No explanation. No markdown. No backticks. No extra text.
- Extract ONLY information explicitly stated in the entry. Never infer or assume.
- If a field has no evidence in the text, return an empty array for it.
- Never hallucinate names, emotions, or themes not present in the text.
- significance must be exactly one of: "low", "medium", or "high". Nothing else.

Required JSON structure:
{
  "people": ["name1", "name2"],
  "emotions": ["emotion1", "emotion2"],
  "themes": ["theme1", "theme2"],
  "keywords": ["word1", "word2", "word3"],
  "significance": "low",
  "significanceScore": 2
}

Rules per field:
- people: only names explicitly mentioned (empty array if none)
- emotions: emotions clearly expressed OR strongly implied by the situation (max 6)
- themes: only topics clearly present like family, growth, loss, joy (max 3)
- keywords: only important words directly from the entry (max 5)
- significance: "high" if life-changing event, "medium" if notable, "low" if routine
- significanceScore: integer 1–10 that must match significance — low=1-3, medium=4-6, high=7-10. Be precise within the range.
Question: $question
Answer: $answer
''';

    final trace = FirebasePerformance.instance.newTrace('tag_memory');
    //TODO: check in firebase
    await trace.start();

    try {
      final result = await _hybridAi.generateHybrid(prompt);
      final text = result['text'] as String;
      final inferenceSource = result['inferenceSource'] as String;
      final tags = _parseJson(text);

      trace.putAttribute('inference_source', inferenceSource);
      await trace.stop();

      String? echoQuestion;
String? echoInferenceSource;
if (tags.isNotEmpty) {
  final echoResult = await _echoService.generateEchoQuestion(
    question: question,
    answer: answer,
    tags: tags,
  );
  echoQuestion = echoResult['question'];
  echoInferenceSource = echoResult['inferenceSource'];
  debugPrint('AI_SERVICE: echo = $echoQuestion ($echoInferenceSource)');
}

return {
  'tags': tags,
  'inferenceSource': inferenceSource,
  'echoQuestion': echoQuestion,
  'echoInferenceSource': echoInferenceSource,
};
    } catch (e, stack) {
      trace.putAttribute('inference_source', 'failed');
      await trace.stop();
      debugPrint('AI_SERVICE: tagging failed — $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'tagMemory failed',
        fatal: false,
      );
      return {'tags': <String, dynamic>{}, 'inferenceSource': 'failed'};
    }
  }

  // ── 2. BASIC NARRATIVE (cloud + template) ──────────────────
  // PII masked on-device before sending. Restored after receiving.
  Future<String> generateBasicNarrative({
    required List<Map<String, dynamic>> memories,
  }) async {
    final rawMemoriesText = memories
        .map((m) => '- ${m['question']}: ${m['answer']}')
        .join('\n');

    // ── Mask PII on-device before sending to cloud ──
    final masked = await _security.maskText(rawMemoriesText);
    final memoriesText = masked.maskedText;
    final entityMap = masked.entityMap;

    final trace = FirebasePerformance.instance.newTrace('basic_narrative');
    await trace.start();

    try {
      final response = await _templateModel.generateContent(
        'lumina-basic-narrative',
        inputs: {
          'memories': memoriesText, // masked — no real names reach the cloud
        },
      );
      trace.putAttribute('source', 'cloud_template');
      await trace.stop();
      await AnalyticsService.logNarrativeGenerated();

      // ── Restore real names locally after receiving response ──
      final rawResponse =
          response.text ?? 'Your story is still being written...';
      return _security.restoreText(rawResponse, entityMap);
    } catch (e, stack) {
      trace.putAttribute('source', 'failed');
      await trace.stop();
      debugPrint('AI_SERVICE: basic narrative failed — $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'generateBasicNarrative failed',
        fatal: false,
      );
      return 'Could not generate your story. Please try again.';
    }
  }

  // ── 3. RICH NARRATIVE (cloud + template) ───────────────────
  // PII masked on-device before sending. Restored after receiving.
  // patternSummary (counts/labels) is NOT masked — already aggregated data.
  Future<String> generateRichNarrative({
    required List<Map<String, dynamic>> memories,
    required Map<String, dynamic> patternSummary,
  }) async {
    final rawMemoriesText = memories
        .map((m) => '- ${m['question']}: ${m['answer']}')
        .join('\n');

    // ── Mask PII on-device before sending to cloud ──
    final masked = await _security.maskText(rawMemoriesText);
    final memoriesText = masked.maskedText;
    final entityMap = masked.entityMap;

    final trace = FirebasePerformance.instance.newTrace('rich_narrative');
    await trace.start();

    try {
      final response = await _templateModel.generateContent(
        'lumina-rich-narrative',
        inputs: {
          'total_memories': '${patternSummary['totalMemories']}',
          'top_people': '${patternSummary['topPeople']}',
          'top_emotions': '${patternSummary['topEmotions']}',
          'top_themes': '${patternSummary['topThemes']}',
          'high_significance_count':
              '${patternSummary['highSignificanceCount']}',
          'memories_text': memoriesText, // masked — no real names reach the cloud
        },
      );
      trace.putAttribute('source', 'cloud_template');
      await trace.stop();
      await AnalyticsService.logNarrativeGenerated();

      // ── Restore real names locally after receiving response ──
      final rawResponse =
          response.text ?? 'Your story is still being written...';
      return _security.restoreText(rawResponse, entityMap);
    } catch (e, stack) {
      trace.putAttribute('source', 'failed');
      await trace.stop();
      debugPrint('AI_SERVICE: rich narrative failed — $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'generateRichNarrative failed',
        fatal: false,
      );
      return 'Could not generate your story. Please try again.';
    }
  }

  // ── 4. CAPSULE SNAPSHOT (hybrid — on-device first) ─────────
  // NO masking — runs on-device via HybridAiService.
  // Data never leaves the device on the on-device path.
  Future<Map<String, dynamic>> generateCapsuleSnapshot({
  required String capsuleMemory,
  required Map<String, dynamic> patternSummary,
}) async {

  // ── Check if on-device is available ──
  // If not available, we mask because generateHybrid will fall back to cloud
  final availability = await _hybridAi.checkOnDeviceAvailability();
  final bool isOnDevice = availability['available'] as bool? ?? false;

  // Mask only if falling back to cloud
  final String safeCapsuleMemory;
  Map<String, String> entityMap = <String, String>{};

  if (!isOnDevice) {
    debugPrint('CAPSULE_SNAPSHOT: on-device unavailable — masking before cloud fallback');
    final masked = await _security.maskText(capsuleMemory);
    safeCapsuleMemory = masked.maskedText;
    entityMap = masked.entityMap;
  } else {
    debugPrint('CAPSULE_SNAPSHOT: on-device available — no masking needed');
    safeCapsuleMemory = capsuleMemory;
  }

  final prompt = '''
You are sealing a time capsule. Write a short snapshot of who this person is RIGHT NOW.

STRICT RULES — you MUST follow all of these:
- Use ONLY the pattern data and memory provided below. Never add details not present.
- Write exactly 2 paragraphs. No more. No less.
- Use second person ("You", "Your"). Warm and specific tone.
- Reference the actual numbers and words from the pattern data.
- Never use generic phrases like "life is a journey" or "you are amazing".
- Return ONLY the snapshot text. No labels. No JSON. No backticks. No preamble.

Pattern data:
- Total memories: ${patternSummary['totalMemories']}
- Most mentioned people: ${patternSummary['topPeople']}
- Dominant emotions: ${patternSummary['topEmotions']}
- Recurring themes: ${patternSummary['topThemes']}

Memory they wrote for this capsule:
$safeCapsuleMemory
''';

  final trace = FirebasePerformance.instance.newTrace('capsule_snapshot');
  await trace.start();

  try {
    final result = await _hybridAi.generateHybrid(prompt);
    final inferenceSource = result['inferenceSource'] as String;
    String text = result['text'] as String;

    // ── If we masked, restore real names in response ──
    if (entityMap.isNotEmpty) {
      text = _security.restoreText(text, entityMap);
    }

    trace.putAttribute('inference_source', inferenceSource);
    trace.putAttribute('pii_masked', (!isOnDevice).toString());
    await trace.stop();
    await AnalyticsService.logCapsuleLocked();
    return {'snapshotText': text, 'inferenceSource': inferenceSource};
  } catch (e, stack) {
    trace.putAttribute('inference_source', 'failed');
    await trace.stop();
    debugPrint('AI_SERVICE: capsule snapshot failed — $e');
    FirebaseCrashlytics.instance.recordError(
      e, stack,
      reason: 'generateCapsuleSnapshot failed',
      fatal: false,
    );
    return {'snapshotText': '', 'inferenceSource': 'failed'};
  }
}

  // ── 5. CAPSULE REVEAL (cloud + template) ───────────────────
  // Both originalMemory and new_memories_text masked using the SAME
  // entityMap so [Person_1] refers to the same person across both sections.
  Future<String> generateCapsuleReveal({
    required String originalMemory,
    required Map<String, dynamic> patternAtSealing,
    required List<Map<String, dynamic>> memoriesSinceSealing,
    required Map<String, dynamic> currentPattern,
  }) async {
    final rawNewMemoriesText = memoriesSinceSealing
        .map((m) => '- ${m['question']}: ${m['answer']}')
        .join('\n');

    // ── Mask PII on-device — build map from new memories first,
    // then apply the SAME map to originalMemory so tokens stay consistent.
    // [Person_1] will always refer to the same person in both sections.
    final masked = await _security.maskText(rawNewMemoriesText);
    final newMemoriesText = masked.maskedText;
    final entityMap = masked.entityMap;

    // Apply same entity map to originalMemory for token consistency
    final maskedOriginalMemory =
        _security.applyExistingMap(originalMemory, entityMap);

    final trace = FirebasePerformance.instance.newTrace('capsule_reveal');
    await trace.start();

    try {
      final response = await _templateModel.generateContent(
        'lumina-capsule-reveal',
        inputs: {
          'total_memories_then': '${patternAtSealing['totalMemories']}',
          'emotions_then': '${patternAtSealing['topEmotions']}',
          'themes_then': '${patternAtSealing['topThemes']}',
          'people_then': '${patternAtSealing['topPeople']}',
          'original_memory': maskedOriginalMemory, // masked
          'total_memories_now': '${currentPattern['totalMemories']}',
          'emotions_now': '${currentPattern['topEmotions']}',
          'themes_now': '${currentPattern['topThemes']}',
          'people_now': '${currentPattern['topPeople']}',
          'new_memories_text': newMemoriesText, // masked
        },
      );
      trace.putAttribute('source', 'cloud_template');
      await trace.stop();
      await AnalyticsService.logCapsuleRevealed();

      // ── Restore real names locally after receiving response ──
      final rawResponse = response.text ??
          'Your capsule could not be revealed. Please try again.';
      return _security.restoreText(rawResponse, entityMap);
    } catch (e, stack) {
      trace.putAttribute('source', 'failed');
      await trace.stop();
      debugPrint('AI_SERVICE: capsule reveal failed — $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'generateCapsuleReveal failed',
        fatal: false,
      );
      return 'Could not reveal your capsule. Please try again.';
    }
  }

  // ── HELPERS ────────────────────────────────────────────────
  Map<String, dynamic> _parseJson(String raw) {
    try {
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('AI_SERVICE: JSON parse failed — $e');
      return {};
    }
  }
}