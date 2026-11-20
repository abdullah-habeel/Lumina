import 'package:get/get.dart';
import 'package:lumina/features/questions/controller/chapter_detail_controller.dart';

class ChapterDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;

    Get.lazyPut<ChapterDetailController>(
      () => ChapterDetailController(
        chapterId: args['chapterId'] as String,
        chapterTitle: args['chapterTitle'] as String,
      ),
    );
  }
}
