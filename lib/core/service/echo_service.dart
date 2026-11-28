import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/core/service/hybrid_ai_service.dart';
import 'package:lumina/core/service/security_service.dart';

class EchoService {
  final HybridAiService _hybridAi = HybridAiService();
  final SecurityService _security = SecurityService();

  Future<Map<String, String?>> generateEchoQuestion({
    required String question,
    required String answer,
    required Map<String, dynamic> tags,
  }) async {
    final people = (tags['people'] as List?)?.join(', ') ?? '';
    final emotions = (tags['emotions'] as List?)?.join(', ') ?? '';
    final themes = (tags['themes'] as List?)?.join(', ') ?? '';

    final contextParts = <String>[];
    if (people.isNotEmpty) contextParts.add('people mentioned: $people');
    if (emotions.isNotEmpty) contextParts.add('emotions: $emotions');
    if (themes.isNotEmpty) contextParts.add('themes: $themes');

    final context = contextParts.join(', ');

    // ── Check on-device availability before deciding whether to mask ──
    final availability = await _hybridAi.checkOnDeviceAvailability();
    final bool isOnDevice = availability['available'] as bool? ?? false;

    final String safeQuestion;
    final String safeAnswer;
    final String safeContext;
    Map<String, String> entityMap = <String, String>{};

    if (!isOnDevice) {
      debugPrint(
          'ECHO_SERVICE: on-device unavailable — masking before cloud fallback');

      // Mask question, answer, and context together in ONE call so the
      // same entity map (e.g. [Person_1]) is used consistently across all three.
      final combined =
          'QUESTION_BLOCK: $question\nANSWER_BLOCK: $answer\nCONTEXT_BLOCK: $context';
      final masked = await _security.maskText(combined);
      entityMap = masked.entityMap;

      safeQuestion = _extractBlock(masked.maskedText, 'QUESTION_BLOCK', question);
      safeAnswer = _extractBlock(masked.maskedText, 'ANSWER_BLOCK', answer);
      safeContext = _extractBlock(masked.maskedText, 'CONTEXT_BLOCK', context);
    } else {
      debugPrint('ECHO_SERVICE: on-device available — no masking needed');
      safeQuestion = question;
      safeAnswer = answer;
      safeContext = context;
    }

    final prompt = '''
You are a memoir interviewer. The writer just wrote this journal entry:

Question: $safeQuestion
Answer: $safeAnswer
Context: $safeContext

Your job: Ask ONE short, specific follow-up question that makes the writer go deeper into this memory.

STRICT RULES:
- One question only. No preamble. No explanation. No advice.
- Never interpret or judge. Never give feedback.
- Never start with "I" or "It seems".
- Ask about a specific detail, moment, or person in the entry.
- Under 20 words.
- Return ONLY the question. Nothing else.
''';

    try {
      final result = await _hybridAi.generateHybrid(prompt);
      var text = (result['text'] as String).trim();
      final inferenceSource = result['inferenceSource'] as String?;
      if (text.isEmpty) return {'question': null, 'inferenceSource': null};

      // ── Restore real names in the generated question, if masked ──
      if (entityMap.isNotEmpty) {
        text = _security.restoreText(text, entityMap);
      }

      return {'question': text, 'inferenceSource': inferenceSource};
    } catch (e, stack) {
      debugPrint('ECHO_SERVICE: generation failed — $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'generateEchoQuestion failed',
        fatal: false,
      );
      return {'question': null, 'inferenceSource': null};
    }
  }

  // ── PRIVATE: extract one labeled block from the masked combined text ──
  String _extractBlock(String maskedCombined, String label, String fallback) {
    final regex =
        RegExp('$label: (.*?)(?:\\n[A-Z_]+_BLOCK:|\$)', dotAll: true);
    final match = regex.firstMatch(maskedCombined);
    return match != null ? match.group(1)!.trim() : fallback;
  }
}