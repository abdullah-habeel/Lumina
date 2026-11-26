import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/core/service/hybrid_ai_service.dart';

class EchoService {
  final HybridAiService _hybridAi = HybridAiService();

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

    final prompt = '''
You are a memoir interviewer. The writer just wrote this journal entry:

Question: $question
Answer: $answer
Context: $context

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
      final text = (result['text'] as String).trim();
      final inferenceSource = result['inferenceSource'] as String?;
      if (text.isEmpty) return {'question': null, 'inferenceSource': null};
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
}