import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxString savedMemory = ''.obs;

  static const int pageCount = 8;

  bool get isLastPage => currentPage.value == pageCount - 1;

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (!isLastPage) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      onGetStarted();
    }
  }

  void skipOnboarding() => Get.offAllNamed(AppRoutes.register);

  // Time Capsule (last page) → Breathe screen, not straight to register.
  void onGetStarted() => Get.offNamed(AppRoutes.breatheScreen);

  void onLogin() => Get.offAllNamed(AppRoutes.login);

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
