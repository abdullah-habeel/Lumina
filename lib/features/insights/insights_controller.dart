import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';

enum InsightRange { week, month, all }

class EmotionData {
  final String emotion;
  final int count;
  final double avgScore;

  EmotionData({
    required this.emotion,
    required this.count,
    required this.avgScore,
  });
}

class InsightsController extends GetxController {
  final Rx<InsightRange> selectedRange = InsightRange.week.obs;
  final RxList<EmotionData> emotionData = <EmotionData>[].obs;
  final RxBool hasData = false.obs;

  late final JournalController _journalController;

  @override
  void onInit() {
    super.onInit();
    _journalController = Get.find<JournalController>();
    ever(_journalController.entries, (_) => _compute());
    ever(selectedRange, (_) => _compute());
    _compute();
  }

  void setRange(InsightRange range) => selectedRange.value = range;

  void _compute() {
    final now = DateTime.now();
    final entries = _journalController.entries.where((e) {
      if (e.taggingStatus != 'complete') return false;
      if (selectedRange.value == InsightRange.week) {
        return now.difference(e.date).inDays <= 7;
      } else if (selectedRange.value == InsightRange.month) {
        return now.difference(e.date).inDays <= 30;
      }
      return true;
    }).toList();

    

    final Map<String, int> counts = {};
    final Map<String, List<int>> scores = {};

    for (final entry in entries) {
      final tags = entry.tags;
      if (tags == null || tags.isEmpty) continue;

      final emotions = tags['emotions'];
      if (emotions is! List) continue;

      final score = entry.significanceScore ?? 5;

      for (final e in emotions) {
        if (e is! String || e.trim().isEmpty) continue;
        final emotion = e.trim().toLowerCase();
        counts[emotion] = (counts[emotion] ?? 0) + 1;
        scores[emotion] = [...(scores[emotion] ?? []), score];
      }
    }

    if (counts.isEmpty) {
      emotionData.clear();
      hasData.value = false;
      return;
    }

    final result = counts.entries.map((entry) {
      final scoreList = scores[entry.key] ?? [5];
      final avg = scoreList.reduce((a, b) => a + b) / scoreList.length;
      return EmotionData(
        emotion: entry.key,
        count: entry.value,
        avgScore: avg,
      );
    }).toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    emotionData.assignAll(result.take(6).toList());
    hasData.value = true;
  }
}