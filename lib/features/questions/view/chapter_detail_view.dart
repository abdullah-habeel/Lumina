import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_background.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/chapter_detail/model/chapter_question_model.dart';
import 'package:lumina/features/library/widgets/animations/chapter_book_cover.dart';
import 'package:lumina/features/questions/controller/chapter_detail_controller.dart';
import '../widgets/chapter_header_widget.dart';
import '../widgets/question_timeline_card.dart';

class ChapterDetailView extends GetView<ChapterDetailController> {
  const ChapterDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => Column(
                children: [
                  const SizedBox(height: 12),
                  ChapterHeaderWidget(
                    title: controller.chapterTitle,
                    answeredCount: controller.answeredCount,
                    totalCount: controller.totalCount,
                    onBack: () => Get.back(),
                    onMenuTap: () {},
                  ),
                  Expanded(
                    child: Obx(() {
                      final visibleQuestions = controller.visibleQuestions;
                      if (visibleQuestions.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'No journal entries saved yet. Write a daily journal entry and it will appear here under Daily Journal.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: visibleQuestions.length,
                        itemBuilder: (context, index) {
                          final question = visibleQuestions[index];
                          final status = controller.statusFor(index);

                          return IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // TimelineDotColumn(
                                  //   status: status,
                                  //   isFirst: index == 0,
                                  //   isLast: index == visibleQuestions.length - 1,
                                  // ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: QuestionTimelineCard(
                                        question: question,
                                        status: status,
                                        onTap: () =>
                                            controller.onQuestionTap(index),
                                        onShare:
                                            status == QuestionStatus.completed
                                            ? () => controller
                                                  .shareQuestionMemory(index)
                                            : null,
                                        onConfirmDelete:
                                            status == QuestionStatus.completed
                                            ? () => controller.confirmDelete(
                                                index,
                                              )
                                            : null,
                                        onDelete:
                                            status == QuestionStatus.completed
                                            ? () => controller.deleteQuestion(
                                                index,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
