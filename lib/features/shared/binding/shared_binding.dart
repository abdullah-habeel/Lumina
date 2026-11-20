import 'package:get/get.dart';
import '../controller/shared_controller.dart';
import '../controller/shared_memory_controller.dart';

class SharedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SharedController>(() => SharedController());
    Get.lazyPut<SharedMemoryController>(() => SharedMemoryController());
  }
}