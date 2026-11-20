import 'package:get/get.dart';
import 'package:lumina/features/auth/controller/auth_controller.dart';
import 'package:lumina/features/auth/controller/username_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<UsernameController>(() => UsernameController());
  }
}
