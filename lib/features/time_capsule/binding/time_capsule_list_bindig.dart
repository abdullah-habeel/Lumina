import 'package:get/get.dart';
import 'package:lumina/features/time_capsule/controller/time_capsule_list_controller.dart';

class TimeCapsuleListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimeCapsuleListController>(() => TimeCapsuleListController());
  }
}
