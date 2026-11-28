import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/services/device_info_service.dart';
import 'package:lumina/core/routes/services/notification_services.dart';
import 'package:lumina/core/service/download_service.dart';
import 'package:lumina/features/music/controller/music_controller.dart';
import 'package:lumina/firebase_options.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _resolveInitialRoute();
  }

  Future<void> _resolveInitialRoute() async {
    debugPrint('SPLASH: started');

    final minimumDelay = Future.delayed(const Duration(milliseconds: 2400));

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Get.put(OnDeviceDownloadService());
unawaited(Get.find<OnDeviceDownloadService>().init());
      debugPrint('SPLASH: Firebase initialized');

      final currentUser = await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 15), onTimeout: () => null);

      debugPrint('SPLASH: got currentUser = $currentUser');

      if (currentUser != null) {
        await Get.find<MusicController>().loadPreference();
        DeviceInfoService.saveDeviceInfo();
      }

      await minimumDelay;

      if (currentUser != null) {
        debugPrint('SPLASH: navigating to /main');
        Get.offAllNamed(AppRoutes.main);

        final pending = NotificationService().pendingPayload;
        if (pending != null) {
          NotificationService().pendingPayload = null;
          NotificationService().handlePayload(pending);
        }
      } else {
        debugPrint('SPLASH: navigating to onboarding');
        Get.offAllNamed(AppRoutes.onboarding);
      }

      debugPrint('SPLASH: navigation call completed');
    } catch (e, st) {
      debugPrint('SPLASH: routing failed: $e\n$st');
      await minimumDelay;
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
