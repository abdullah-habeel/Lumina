import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_background.dart';
import 'package:lumina/features/onboarding/controller/onboarding_controller.dart';
import 'package:lumina/features/onboarding/screens/deleted_leaf_screen.dart';
import 'package:lumina/features/onboarding/screens/onboarding_ai_capsule_screen.dart';
import 'package:lumina/features/onboarding/screens/onboarding_ai_privacy_screen.dart';
import 'package:lumina/features/onboarding/screens/onboarding_ai_tagging_screen.dart';
import 'package:lumina/features/onboarding/screens/onboarding_book_screen.dart';
import 'package:lumina/features/onboarding/widgets/onboarding_bottom_action.dart';
import 'package:lumina/features/onboarding/widgets/onboarding_wave_indicator.dart';
import 'package:lumina/features/onboarding/screens/onboarding_tree_screen.dart';
import 'package:lumina/features/onboarding/screens/onboarding_write_screen.dart';
import 'package:lumina/features/onboarding/screens/share_partner_onboarding_screen.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return DaylightPlainBackground(
      debugOverrideHour: 10,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              _buildSkipRow(controller),

              Obx(
                () => OnboardingWaveIndicator(
                  totalPages: OnboardingController.pageCount,
                  currentIndex: controller.currentPage.value,
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: Obx(
                  () => PageView(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    physics: controller.currentPage.value == 0
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    children: [
                      const OnboardingWriteScreen(),         // 0
                      const OnboardingBookScreen(),           // 1
                      OnboardingTreeScreen(
                          onContinue: controller.nextPage),   // 2
                      const OnboardingDeletedLeavesScreen(),  // 3
                      const OnboardingAiTagsScreen(),         // 5
                      const OnboardingAiPrivacyScreen(),      // 6
                      const OnboardingAiCapsuleScreen(),      // 7
                      const OnboardingSharePartnerScreen(),   // 8
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const OnboardingBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipRow(OnboardingController controller) {
    return Obx(() {
      if (controller.isLastPage) {
        return const SizedBox(height: 48);
      }

      return Padding(
        padding: const EdgeInsets.only(top: 12, right: 20),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: controller.skipOnboarding,
            child: const Text(
              'Skip',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 12,
                color: Color(0xFFA89B8C),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    });
  }
}