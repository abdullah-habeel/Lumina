import 'package:get/get.dart';

import 'package:lumina/features/review/controller/review_controller.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ReviewController>(ReviewController(), permanent: true);
  }
}
