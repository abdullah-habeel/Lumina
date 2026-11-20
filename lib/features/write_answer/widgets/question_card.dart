import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/write_answer/widgets/calender_badge.dart';

class QuestionCard extends StatelessWidget {
  final String month;
  final String day;

  /// Static mode (daily question): pass the question text directly.
  final String? question;

  /// Editable mode (daily journal): pass a controller instead.
  final TextEditingController? headingController;

  /// Small italic label above the title — defaults based on mode
  /// if not explicitly overridden.
  final String? label;

  const QuestionCard({
    super.key,
    required this.month,
    required this.day,
    this.question,
    this.headingController,
    this.label,
  }) : assert(
         question != null || headingController != null,
         'Provide either question or headingController',
       );

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final cardBg = DaylightAppColors.cardBackground(hour);
    final border = DaylightAppColors.borderGold(hour);
    final accent = DaylightAppColors.accentGold(hour);
    final textColor = DaylightAppColors.cardText(hour);
    final subtextColor = DaylightAppColors.cardSubtext(hour);

    final borderRadius = BorderRadius.circular(20);
    final isEditable = headingController != null;
    final resolvedLabel =
        label ?? (isEditable ? 'Daily Journal' : "Today's Question");

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.fromLTRB(70, 20, 20, 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: borderRadius,
          border: Border.all(color: border.withOpacity(0.5)),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Align(
              alignment: const Alignment(-2.3, 0),
              child: Image.asset(
                AppImages.answerflower,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resolvedLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      isEditable
                          ? TextField(
                              controller: headingController,
                              maxLength: 60,
                              maxLines: null,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                counterText: '',
                                hintText: 'Write your title here...',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: subtextColor.withOpacity(0.6),
                                ),
                              ),
                            )
                          : Text(
                              question!,
                              style: GoogleFonts.abhayaLibre(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CalendarBadge(month: month, day: day),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
