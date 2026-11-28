import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/story/controller/story_controller.dart';
import 'package:lumina/features/story/widgets/cloud_generate_button.dart';
import 'package:lumina/features/story/widgets/pattern_summary_card.dart';
import 'package:lumina/features/story/widgets/toggle_bar.dart';

class CloudStoryTab extends StatelessWidget {
  final StoryController controller;
  const CloudStoryTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final headingColor =
          DaylightAppColors.headingText(DaylightTime.of(context));
      final subtextColor =
          DaylightAppColors.headingSubtext(DaylightTime.of(context));
      final bookTitleColor =
          DaylightAppColors.bookTitleText(DaylightTime.of(context));
      final bookSubtitleColor =
          DaylightAppColors.bookTitleSubtext(DaylightTime.of(context));

      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: headingColor),
              const SizedBox(height: 20),
              Text(
                'Weaving your story...',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 16,
                  color: headingColor,
                ),
              ),
            ],
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 16,
                    color: headingColor,
                  ),
                ),
                const SizedBox(height: 24),
                CloudGenerateButton(onPressed: controller.generateStory),
              ],
            ),
          ),
        );
      }

      if (!controller.hasStory) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your story is waiting\nto be told.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: bookTitleColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cloud AI will weave your memories into\na narrative that is uniquely yours.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 15,
                    color: bookSubtitleColor,
                  ),
                ),
                const SizedBox(height: 36),
                CloudGenerateButton(onPressed: controller.generateStory),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          ToggleBar(controller: controller),
          if (controller.showRich.value)
            PatternSummaryCard(patternSummary: controller.patternSummary),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      controller.currentNarrative,
                      key: ValueKey(controller.showRich.value),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 17,
                        height: 1.8,
                        color: headingColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: subtextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Names protected · Processed by cloud AI',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 12,
                          color: subtextColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: CloudGenerateButton(
              label: 'Regenerate',
              onPressed: controller.generateStory,
            ),
          ),
        ],
      );
    });
  }
}