import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/models/controller/home_controller.dart';
import 'package:lumina/features/home/widgets/apptextstyle.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

class EchoCard extends StatelessWidget {
  const EchoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final hour = DaylightTime.of(context);

    final cardBg = DaylightAppColors.cardBackground(hour);
    final border = DaylightAppColors.borderGold(hour);
    final accent = DaylightAppColors.accentGold(hour);
    final textColor = DaylightAppColors.cardText(hour);
    final subtextColor = DaylightAppColors.cardSubtext(hour);
    final shadowColor = DaylightAppColors.shadow(hour);

    return Obx(() {
      final echoQuestion = controller.lastEchoQuestion.value;

      // Hide card if no echo question yet
      if (echoQuestion == null) return const SizedBox.shrink();

      return SizedBox(
        height: 105,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Row(
              children: [
                // ── Left icon area ──────────────────────────────
                SizedBox(
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: Opacity(
                          opacity: 0.65,
                          child: Image.asset(
                            AppImages.chapterBeginningsBg,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
                        child: Opacity(
                          opacity: 0.58,
                          child: Image.asset(
                            AppImages.homebook,
                            height: 65,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Divider ─────────────────────────────────────
                Container(
                  width: 1,
                  height: 50,
                  color: accent.withOpacity(0.3),
                ),

                // ── Text area ───────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
  children: [
    Text(
      '💭 Sit with this',
      style: AppTextStyles.cardTitle.copyWith(
        color: textColor,
        fontSize: 13,
      ),
    ),
    const SizedBox(width: 6),
    Obx(() {
      final source = controller.lastEchoInferenceSource.value;
      if (source == null) return const SizedBox.shrink();
      final isOnDevice = source == 'ON_DEVICE';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isOnDevice
              ? Colors.green.withOpacity(0.15)
              : Colors.blue.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOnDevice
                ? Colors.green.withOpacity(0.4)
                : Colors.blue.withOpacity(0.4),
            width: 0.8,
          ),
        ),
        child: Text(
          isOnDevice ? '🟢 On-device' : '☁️ Cloud',
          style: TextStyle(
            fontSize: 9,
            color: isOnDevice ? Colors.green[700] : Colors.blue[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }),
  ],
),
                        const SizedBox(height: 4),
                        Text(
                          echoQuestion,
                          style: AppTextStyles.cardSubtitle.copyWith(
                            color: subtextColor,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}