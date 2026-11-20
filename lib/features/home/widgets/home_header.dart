import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/models/controller/home_controller.dart';
import 'package:lumina/features/home/widgets/apptextstyle.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Hello, ${controller.userName.value}',
                    style: AppTextStyles.greeting.copyWith(
                      color: DaylightAppColors.headingText(
                        DaylightTime.of(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "What's your story today?",
                  style: AppTextStyles.subGreeting.copyWith(
                    color: DaylightAppColors.headingSubtext(
                      DaylightTime.of(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Announcement horn icon ──────────────────────────────
        
        // ── end horn icon ───────────────────────────────────────
      ],
    );
  }
}
