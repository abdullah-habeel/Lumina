import 'package:get/get.dart';
import 'package:lumina/features/time_capsule/controller/time_capsule_controller.dart';

class TimeCapsuleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimeCapsuleController>(() => TimeCapsuleController());
  }
}
