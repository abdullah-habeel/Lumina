import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/apptextstyle.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

class ChapterHeaderWidget extends StatelessWidget {
  final String title;
  final int answeredCount;
  final int totalCount;
  final VoidCallback onBack;
  final VoidCallback onMenuTap;

  const ChapterHeaderWidget({
    super.key,
    required this.title,
    required this.answeredCount,
    required this.totalCount,
    required this.onBack,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final headingColor = DaylightAppColors.headingText(hour);
    final subtextColor = DaylightAppColors.headingSubtext(hour);

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: headingColor,
              ),
              onPressed: onBack,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.greeting.copyWith(color: headingColor),
              ),
            ),
            // IconButton(
            //   icon: Icon(Icons.more_horiz, color: headingColor),
            //   onPressed: onMenuTap,
            // ),
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$answeredCount / $totalCount',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: subtextColor,
                ),
              ),
              TextSpan(
                text: ' Questions answered',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
