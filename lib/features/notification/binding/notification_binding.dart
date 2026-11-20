import 'package:get/get.dart';
import 'package:lumina/features/notification/controller/notification_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}
