import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import '../controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<JournalController>()) {
      Get.lazyPut<JournalController>(() => JournalController(), fenix: true);
    }
    if (!Get.isRegistered<SharedController>()) {
      Get.lazyPut<SharedController>(() => SharedController(), fenix: true);
    }
    if (!Get.isRegistered<SharedMemoryController>()) {
      Get.lazyPut<SharedMemoryController>(
        () => SharedMemoryController(),
        fenix: true,
      );
    }
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
