import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/core/service/analystics_service.dart';

import 'hybrid_ai_service.dart';

class AiService {
  final HybridAiService _hybridAi = HybridAiService();

  late final TemplateGenerativeModel _templateModel =
      FirebaseAI.googleAI().templateGenerativeModel();

  // ── 1. TAG A MEMORY (hybrid — on-device first) ─────────────
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
  "significance": "low"
}

Rules per field:
- people: only names explicitly mentioned (empty array if none)
- emotions: only emotions clearly expressed (max 3)
- themes: only topics clearly present like family, growth, loss, joy (max 3)
- keywords: only important words directly from the entry (max 5)
- significance: "high" if life-changing event, "medium" if notable, "low" if routine

Question: $question
Answer: $answer
''';

    final trace = FirebasePerformance.instance.newTrace('tag_memory');
    await trace.start();

    try {
      final result = await _hybridAi.generateHybrid(prompt);
      final text = result['text'] as String;
      final inferenceSource = result['inferenceSource'] as String;
      final tags = _parseJson(text);

      trace.putAttribute('inference_source', inferenceSource);
      await trace.stop();

      return {'tags': tags, 'inferenceSource': inferenceSource};
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
  Future<String> generateBasicNarrative({
    required List<Map<String, dynamic>> memories,
  }) async {
    final memoriesText = memories
        .map((m) => '- ${m['question']}: ${m['answer']}')
        .join('\n');

    final trace = FirebasePerformance.instance.newTrace('basic_narrative');
    await trace.start();

    try {
      final response = await _templateModel.generateContent(
        'lumina-basic-narrative',
        inputs: {
          'memories': memoriesText,
        },
      );
      trace.putAttribute('source', 'cloud_template');
      await trace.stop();
      await AnalyticsService.logNarrativeGenerated();
      return response.text ?? 'Your story is still being written...';
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
  Future<String> generateRichNarrative({
    required List<Map<String, dynamic>> memories,
    required Map<String, dynamic> patternSummary,
  }) async {
    final memoriesText = memories
        .map((m) => '- ${m['question']}: ${m['answer']}')
        .join('\n');

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
          'high_significance_count': '${patternSummary['highSignificanceCount']}',
          'memories_text': memoriesText,
        },
      );
      trace.putAttribute('source', 'cloud_template');
      await trace.stop();
      await AnalyticsService.logNarrativeGenerated();
      return response.text ?? 'Your story is still being written...';
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
  Future<Map<String, dynamic>> generateCapsuleSnapshot({
    required String capsuleMemory,
    required Map<String, dynamic> patternSummary,
  }) async {
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
$capsuleMemory
''';

    final trace = FirebasePerformance.instance.newTrace('capsule_snapshot');
    await trace.start();

    try {
      final result = await _hybridAi.generateHybrid(prompt);
      final text = result['text'] as String;
      final inferenceSource = result['inferenceSource'] as String;
      trace.putAttribute('inference_source', inferenceSource);
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
  Future<String> generateCapsuleReveal({
    required String originalMemory,
    required Map<String, dynamic> patternAtSealing,
    required List<Map<String, dynamic>> memoriesSinceSealing,
    required Map<String, dynamic> currentPattern,
  }) async {
    final newMemoriesText = memoriesSinceSealing
        .map((m) => '- ${m['question']}: ${m['answer']}')
        .join('\n');

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
          'original_memory': originalMemory,
          'total_memories_now': '${currentPattern['totalMemories']}',
          'emotions_now': '${currentPattern['topEmotions']}',
          'themes_now': '${currentPattern['topThemes']}',
          'people_now': '${currentPattern['topPeople']}',
          'new_memories_text': newMemoriesText,
        },
      );
      trace.putAttribute('source', 'cloud_template');
      await trace.stop();
      await AnalyticsService.logCapsuleRevealed();
      return response.text ?? 'Your capsule could not be revealed. Please try again.';
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