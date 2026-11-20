import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/core/service/ai_service.dart';
import 'package:lumina/core/service/consent_service.dart';
import 'package:lumina/core/service/pattern_service.dart';
import 'package:lumina/features/story/widgets/consent_dialogue_widget.dart';

class StoryController extends GetxController {
  final AiService _aiService = AiService();
  final PatternService _patternService = PatternService();
  final ConsentService _consentService = ConsentService();
  final JournalController _journalController = Get.find<JournalController>();

  // ── State ──────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString basicNarrative = ''.obs;
  final RxString richNarrative = ''.obs;
  final RxBool showRich = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> patternSummary = <String, dynamic>{}.obs;

  // ── Generate ───────────────────────────────────────────────
  Future<void> generateStory() async {
    final entries = _journalController.entries;

    if (entries.isEmpty) {
      errorMessage.value = 'Write some memories first.';
      return;
    }

    // ── Consent Gate ───────────────────────────────────────
    final hasConsent = await _consentService.hasConsented();
    if (!hasConsent) {
      final granted = await Get.dialog<bool>(
        const ConsentDialog(),
        barrierDismissible: false,
      );

      if (granted != true) {
        errorMessage.value =
            'Please allow Cloud AI to write your story.';
        return;
      }

      await _consentService.saveConsent(true);
    }

    // ── Generate ───────────────────────────────────────────
    isLoading.value = true;
    errorMessage.value = '';
    basicNarrative.value = '';
    richNarrative.value = '';

    try {
      final memories = _buildMemoriesList(entries);
      final pattern = _patternService.computePattern(entries);
      patternSummary.assignAll(pattern);

      final results = await Future.wait([
        _aiService.generateBasicNarrative(memories: memories),
        _aiService.generateRichNarrative(
          memories: memories,
          patternSummary: pattern,
        ),
      ]);

      basicNarrative.value = results[0];
      richNarrative.value = results[1];
    } catch (e) {
      errorMessage.value = 'Could not generate your story. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Toggle ─────────────────────────────────────────────────
  void toggleMode() {
    showRich.value = !showRich.value;
  }

  // ── Helpers ────────────────────────────────────────────────
  List<Map<String, dynamic>> _buildMemoriesList(List<JournalEntry> entries) {
    return entries
        .where((e) => e.body != null && e.body!.trim().isNotEmpty)
        .map((e) => {
              'question': e.question,
              'answer': e.body ?? '',
            })
        .toList();
  }

  String get currentNarrative =>
      showRich.value ? richNarrative.value : basicNarrative.value;

  bool get hasStory =>
      basicNarrative.value.isNotEmpty && richNarrative.value.isNotEmpty;
}