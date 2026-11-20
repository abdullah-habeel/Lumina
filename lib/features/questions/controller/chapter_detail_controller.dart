// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/book_display/view/book_display_view.dart';
import 'package:lumina/features/chapter_detail/model/chapter_question_model.dart';
import 'package:lumina/features/delete_leaf/controller/delete_leaf_controller.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import 'package:lumina/features/shared/model/shared_model.dart';
import 'package:lumina/features/write_answer/view/write_answer_view.dart';

class ChapterDetailController extends GetxController {
  final String chapterId;
  final String chapterTitle;

  ChapterDetailController({
    required this.chapterId,
    required this.chapterTitle,
  });

  final JournalController _journalController = Get.find<JournalController>();

  final RxList<ChapterQuestionModel> questions = <ChapterQuestionModel>[].obs;

  int get totalCount => questions.length;
  int get answeredCount => questions.where((q) => q.isAnswered).length;

  int get currentIndex => questions.indexWhere((q) => !q.isAnswered);

  bool get answeredToday => _journalController.hasAnsweredToday(chapterId);

  /// Only answered questions + the single current one (hides future locked ones).
  List<ChapterQuestionModel> get visibleQuestions {
    final idx = currentIndex;
    if (idx == -1) return questions; // chapter fully completed
    return questions.sublist(0, idx + 1);
  }

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
    ever(_journalController.entries, (_) => loadQuestions());
  }

  void loadQuestions() {
    if (chapterId == 'daily_journal') {
      final dailyEntries =
          _journalController.entries
              .where((e) => e.chapterId == chapterId)
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      final mapped = dailyEntries
          .map(
            (entry) => ChapterQuestionModel(
              id: entry.questionId,
              date: entry.date,
              question: entry.question,
              isAnswered: true,
            ),
          )
          .toList();

      questions.assignAll(mapped);
      return;
    }

    ;
    final mapped = <ChapterQuestionModel>[];

    // for (final q in raw) {
    //   final entry = _journalController.entryFor(chapterId, q.id);
    //   if (entry != null) {
    //     mapped.add(q.copyWith(isAnswered: true, date: entry.date));
    //   } else {
    //     mapped.add(q);
    //   }
    // }

    questions.assignAll(mapped);

    final idx = currentIndex;
    if (idx != -1 && idx < questions.length) {
      questions[idx] = questions[idx].copyWith(date: DateTime.now());
    }
  }

  QuestionStatus statusFor(int index) {
    final question = questions[index];
    if (question.isAnswered) return QuestionStatus.completed;
    if (index == currentIndex && !answeredToday) return QuestionStatus.current;
    return QuestionStatus.locked;
  }

  void onQuestionTap(int index) {
    final status = statusFor(index);

    if (status == QuestionStatus.locked) {
      if (index == currentIndex && answeredToday) {
        Get.snackbar(
          'One question a day',
          "You've answered today's question. Come back tomorrow for the next one.",
        );
      }
      return;
    }

    final question = questions[index];

    if (status == QuestionStatus.completed) {
      final answeredEntries =
          questions
              .where((q) => q.isAnswered)
              .map((q) => _journalController.entryFor(chapterId, q.id))
              .whereType<JournalEntry>()
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      print('=== TAP DEBUG ===');
      print('Tapped question.id: ${question.id}');
      for (int i = 0; i < answeredEntries.length; i++) {
        print(
          '[$i] questionId: ${answeredEntries[i].questionId} | date: ${answeredEntries[i].date}',
        );
      }
      final tappedIndex = answeredEntries.indexWhere(
        (e) => e.questionId == question.id,
      );
      print('tappedIndex: $tappedIndex');
      print('=================');

      Get.to(
        () => BookScreen(
          key: ValueKey(question.id),
          entries: answeredEntries,
          initialIndex: tappedIndex < 0 ? 0 : tappedIndex,
          isReadOnly: true,
        ),
      );
      return;
    }

    // current
    Get.to(
      () => WriteAnswerScreen(
        question: question.question,
        date: question.date,
        chapterId: chapterId,
        questionId: question.id,
      ),
    );
  }

  Future<bool> confirmDelete(int index) async {
    final question = questions[index];
    final entry = _journalController.entryFor(chapterId, question.id);
    if (entry == null) return false;

    final shouldDelete = await Get.bottomSheet<bool>(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.chapterCardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.chapterTextMuted.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.chapterHighlightBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.accentBrown,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete this memory?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 22,
                  color: AppColors.chapterTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will remove it from your chapter and book.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.chapterTextDark,
                        side: const BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Keep'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBrown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );

    return shouldDelete == true;
  }

  Future<bool> deleteQuestion(int index) async {
    final question = questions[index];
    final entry = _journalController.entryFor(chapterId, question.id);
    if (entry == null) return false;

    try {
      final deletedLeafController = Get.find<DeletedLeafController>();
      final sortedEntries = List<JournalEntry>.from(_journalController.entries)
        ..sort((a, b) => a.date.compareTo(b.date));

      final skipped = deletedLeafController.allSkippedIndices;
      int anchorIndex = 0;

      for (int i = 0; i < sortedEntries.length; i++) {
        while (skipped.contains(anchorIndex)) {
          anchorIndex++;
        }
        final e = sortedEntries[i];
        if (e.chapterId == entry.chapterId &&
            e.questionId == entry.questionId) {
          break;
        }
        anchorIndex++;
      }

      await _journalController.deleteEntry(entry);
      await deletedLeafController.onMemoryDeleted(anchorIndex);

      Get.snackbar('Memory deleted', 'Your chapter has been updated.');
      return true;
    } catch (_) {
      Get.snackbar('Could not delete', 'Please try again in a moment.');
      return false;
    }
  }

  Future<void> shareQuestionMemory(int index) async {
    final question = questions[index];
    final entry = _journalController.entryFor(chapterId, question.id);
    if (entry == null) return;

    final trustedController = Get.find<SharedController>();
    final memoryController = Get.find<SharedMemoryController>();

    if (trustedController.trustedPeople.isEmpty) {
      Get.snackbar('No one to share with yet', 'Add someone you trust first.');
      return;
    }
    final hour = DaylightTime.of(Get.context!);
    final sheetBg = DaylightAppColors.cardBackground(hour);
    final sheetBorder = DaylightAppColors.borderGold(hour);

    final TrustedPerson? chosen = await Get.bottomSheet<TrustedPerson>(
      Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: sheetBorder, width: 1.5)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.chapterTextMuted.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  'Share memory with',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 21,
                    color: AppColors.chapterTextDark,
                  ),
                ),
              ),
              Flexible(
                child: Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: trustedController.trustedPeople.length,
                    itemBuilder: (context, index) {
                      final person = trustedController.trustedPeople[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryGreen.withOpacity(
                            0.1,
                          ),
                          child: Text(
                            person.name.isNotEmpty
                                ? person.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          person.name,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          '@${person.username}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.chapterTextMuted,
                        ),
                        onTap: () => Get.back(result: person),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );

    if (chosen == null) return;

    await memoryController.shareEntryDirectly(entry, chosen);
  }
}
