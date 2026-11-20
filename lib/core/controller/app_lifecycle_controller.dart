import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lumina/features/pin/controller/pin_controller.dart';

class AppLifecycleController extends GetxController
    with WidgetsBindingObserver {
  late final PinController pinController;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    pinController = Get.find<PinController>();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      pinController.lockApp();
    }
  }
}
