import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/services/notification_services.dart';
import 'package:lumina/core/service/ai_service.dart';
import 'package:lumina/core/service/consent_service.dart';
import 'package:lumina/core/service/pattern_service.dart';
import 'package:lumina/features/story/widgets/consent_dialogue_widget.dart';
import 'package:lumina/features/time_capsule/model/time_capsule_model.dart';

class TimeCapsuleController extends GetxController {
  final message = ''.obs;
  final unlockDate = Rxn<DateTime>();
  final selectedPreset = '1 Year'.obs;
  final shareWithPartner = false.obs;
  final isSealing = false.obs;

  final _aiService = AiService();
  final _patternService = PatternService();
  final _consentService = ConsentService();

  final presets = <String>['1 Month', '6 Months', '1 Year', '5 Years'];

  @override
  void onInit() {
    super.onInit();
    selectPreset('1 Year');
  }

  void selectPreset(String preset) {
    selectedPreset.value = preset;
    final now = DateTime.now();
    switch (preset) {
      case '1 Month':
        unlockDate.value = DateTime(now.year, now.month + 1, now.day);
        break;
      case '6 Months':
        unlockDate.value = DateTime(now.year, now.month + 6, now.day);
        break;
      case '1 Year':
        unlockDate.value = DateTime(now.year + 1, now.month, now.day);
        break;
      case '5 Years':
        unlockDate.value = DateTime(now.year + 5, now.month, now.day);
        break;
    }
  }

  void setCustomDate(DateTime date) {
    unlockDate.value = date;
    selectedPreset.value = '';
  }

  void toggleShare(bool value) => shareWithPartner.value = value;

  void updateMessage(String value) => message.value = value;

  Future<void> sealCapsule() async {
    if (message.value.trim().isEmpty || unlockDate.value == null) {
      Get.snackbar('Almost there', 'Write a message and pick an unlock date.');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Get.snackbar('Error', 'You need to be signed in to seal a capsule.');
      return;
    }

    // ── Consent Gate ─────────────────────────────────────────
    final hasConsent = await _consentService.hasConsented();
    if (!hasConsent) {
      final granted = await Get.dialog<bool>(
        const ConsentDialog(),
        barrierDismissible: false,
      );

      if (granted != true) {
        Get.snackbar(
          'Cloud AI needed',
          'Enable Cloud AI in Settings to seal a capsule with AI snapshot.',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      await _consentService.saveConsent(true);
    }

    isSealing.value = true;

    try {
      // ── 1. Compute current pattern ─────────────────────────
      final journalController = Get.find<JournalController>();
      final entries = journalController.entries;
      final patternSummary = _patternService.computePattern(entries);

      // ── 2. Save to Firestore immediately ───────────────────
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('time_capsules')
          .doc();

      final capsule = TimeCapsuleModel(
        id: docRef.id,
        title: message.value.trim(),
        unlockDate: unlockDate.value!,
        sealedDate: DateTime.now(),
        spineColor: const Color(0xff32402F),
        patternAtSealing: patternSummary,
        snapshotText: null,
      );

      await docRef.set(capsule.toMap());

      // ── 3. Schedule notification ───────────────────────────
      NotificationService().scheduleCapsuleUnlock(
        id: docRef.id.hashCode & 0x7fffffff,
        title: capsule.title,
        unlockDate: capsule.unlockDate,
        payload: docRef.id,
      );

      // ── 4. Generate AI snapshot in background ──────────────
      _generateSnapshotInBackground(
        docRef: docRef,
        capsuleMemory: message.value.trim(),
        patternSummary: patternSummary,
      );

      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Could not seal your capsule. Please try again.');
    } finally {
      isSealing.value = false;
    }
  }

  void _generateSnapshotInBackground({
    required DocumentReference docRef,
    required String capsuleMemory,
    required Map<String, dynamic> patternSummary,
  }) {
    Future(() async {
      try {
        final result = await _aiService.generateCapsuleSnapshot(
          capsuleMemory: capsuleMemory,
          patternSummary: patternSummary,
        );

        final snapshotText = result['snapshotText'] as String? ?? '';
        await docRef.update({'snapshotText': snapshotText});
      } catch (e) {
        debugPrint('TIME_CAPSULE: snapshot generation failed — $e');
      }
    });
  }
}