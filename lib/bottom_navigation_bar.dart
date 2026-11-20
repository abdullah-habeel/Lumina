import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/features/home/view/home_view.dart';
import 'package:lumina/features/home/widgets/bottom_nav.dart';
import 'package:lumina/features/journelview/daily_journal_write_view.dart';
import 'package:lumina/features/library/library_view.dart';
import 'package:lumina/features/music/widgets/music_screen_wrapper.dart';
import 'package:lumina/features/profile/controller/profile_controller.dart';
import 'package:lumina/features/profile/view/profile_view.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import 'package:lumina/features/shared/view/shared_home_view.dart';

class BottomNavController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
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
  }

  void changeTab(int index) {
    if (index == 2) {
      Get.to(() => DailyJournalWriteScreen(date: DateTime.now()));
      return;
    }
    currentIndex.value = index;
  }
}

class BottomNavScreen extends StatelessWidget {
  const BottomNavScreen({super.key});

  static final _libraryKey = GlobalKey<LibraryViewState>();
  static final _profileKey = GlobalKey<ProfileViewState>();
  static final homeKey = GlobalKey<HomeViewState>();
  static final _sharedKey = GlobalKey<SharedHomeViewState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController());

    final pages = [
      HomeView(key: BottomNavScreen.homeKey),
      SharedHomeView(key: _sharedKey),
      const SizedBox.shrink(),
      LibraryView(key: _libraryKey),
      ProfileView(key: _profileKey),
    ];

    return MusicScreenWrapper(
      child: Obx(
        () => Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: controller.currentIndex.value,
                  children: pages,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: HomeBottomNav(
                  currentIndex: controller.currentIndex.value,
                  onTap: (index) {
                    if (index == 0) {
                      BottomNavScreen.homeKey.currentState
                          ?.replayCardAnimation();
                    }
                    if (index == 1) {
                      _sharedKey.currentState?.replayAnimation();
                    }
                    if (index == 3) {
                      _libraryKey.currentState?.playAnimation();
                    }
                    if (index == 4) {
                      _profileKey.currentState?.playAnimation();
                    }
                    controller.changeTab(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
