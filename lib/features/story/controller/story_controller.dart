import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/core/service/ai_service.dart';
import 'package:lumina/core/service/connectivity_service.dart';
import 'package:lumina/core/service/pattern_service.dart';
import 'package:lumina/core/service/privacy_gate_service.dart';
import 'package:lumina/features/ai_log/widgets/ondevice_summary_screen.dart';
import 'package:lumina/features/ai_log/widgets/private_gate_screen.dart';

class StoryController extends GetxController {
  final AiService _aiService = AiService();
  final PatternService _patternService = PatternService();
  final PrivacyGateService _privacyGateService = PrivacyGateService();
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

    // ── Privacy Gate ───────────────────────────────────────
    final choice = await _privacyGateService.getChoice();

    if (choice == PrivacyChoice.notAsked) {
      final result = await Get.to<bool>(() => const PrivacyGateScreen());

      if (result != true) {
        // User chose on-device only — show on-device summary
        final pattern = _patternService.computePattern(entries);
        patternSummary.assignAll(pattern);
        await Get.to(() => OnDeviceSummaryScreen(patternSummary: pattern));
        return;
      }
    }

    if (choice == PrivacyChoice.onDeviceOnly) {
      // User previously chose on-device only — show summary
      final pattern = _patternService.computePattern(entries);
      patternSummary.assignAll(pattern);
      await Get.to(() => OnDeviceSummaryScreen(patternSummary: pattern));
      return;
    }

    // ── choice == cloudEnabled → proceed to generation ─────
    // ── Connectivity check ─────────────────────────────────
    final isConnected = await ConnectivityService().isConnected();
    if (!isConnected) {
      Get.snackbar(
        'No internet connection',
        'Your memories are safe on-device. Connect to generate your story.',
        backgroundColor: const Color(0xFF3B2F1E),
        colorText: const Color(0xFFF5EBD5),
        icon: const Icon(
          Icons.wifi_off_rounded,
          color: Color(0xFFF5EBD5),
        ),
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );
      return;
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