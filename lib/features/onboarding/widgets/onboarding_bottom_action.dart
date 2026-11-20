import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumina/features/onboarding/controller/onboarding_controller.dart';

class OnboardingBottomActions extends StatefulWidget {
  const OnboardingBottomActions({super.key});

  @override
  State<OnboardingBottomActions> createState() =>
      _OnboardingBottomActionsState();
}

class _OnboardingBottomActionsState extends State<OnboardingBottomActions> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Obx(() {
      final bool isLast = controller.isLastPage;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) {
                setState(() => _pressed = false);
                HapticFeedback.lightImpact();
                if (isLast) {
                  controller.onGetStarted();
                } else {
                  controller.nextPage();
                }
              },
              onTapCancel: () => setState(() => _pressed = false),
              child: AnimatedScale(
                scale: _pressed ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _pressed
                        ? const Color(0xFF163320) // darker on press
                        : const Color(0xFF1f3d2e),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? 'Create My Lifebook' : 'Continue',
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: Color(0xFFF5EDD9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: Color(0xFFF5EDD9),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}
