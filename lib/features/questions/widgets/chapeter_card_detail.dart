import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/features/chapter_detail/model/chapter_question_model.dart';
import 'package:lumina/features/questions/controller/chapter_detail_controller.dart';

import '../widgets/chapter_header_widget.dart';
import '../widgets/question_timeline_card.dart';

class ChapterDetailView extends GetView<ChapterDetailController> {
  const ChapterDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBD7),
      body: SafeArea(
        child: Column(
          children: [
            ChapterHeaderWidget(
              title: controller.chapterTitle,
              answeredCount: controller.answeredCount,
              totalCount: controller.totalCount,
              onBack: () => Get.back(),
              onMenuTap: () {},
            ),

            Expanded(
              child: Obx(() {
                final questions = controller.visibleQuestions;

                if (questions.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final status = controller.statusFor(index);

                    return QuestionTimelineCard(
                      key: ValueKey(
                        '${question.question}_${question.date.toIso8601String()}',
                      ),
                      question: question,
                      status: status,
                      onTap: () {
                        controller.onQuestionTap(index);
                      },
                      onShare: status == QuestionStatus.completed
                          ? () {
                              controller.shareQuestionMemory(index);
                            }
                          : null,
                      onConfirmDelete: status == QuestionStatus.completed
                          ? () => controller.confirmDelete(index)
                          : null,
                      onDelete: status == QuestionStatus.completed
                          ? () => controller.deleteQuestion(index)
                          : null,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No questions yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF6E5945).withOpacity(.65),
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
