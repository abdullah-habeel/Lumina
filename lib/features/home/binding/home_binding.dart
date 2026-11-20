import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/features/delete_leaf/controller/delete_leaf_controller.dart';
import 'package:lumina/features/home/models/controller/home_controller.dart';
import 'package:lumina/features/profile/controller/profile_controller.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import 'package:lumina/features/time_capsule/controller/time_capsule_list_controller.dart';

class HomeBinding extends Bindings {
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
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    }
    Get.lazyPut<HomeController>(() => HomeController());
    Get.put<DeletedLeafController>(DeletedLeafController(), permanent: true);
    Get.put<TimeCapsuleListController>(
      TimeCapsuleListController(),
      permanent: true,
    );
     // ← new
  }
}
