import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/story/controller/story_controller.dart';
import 'package:lumina/features/story/widgets/cloud_story_tab.dart';
import 'package:lumina/features/story/widgets/main_tab_bar.dart';
import 'package:lumina/features/story/widgets/on_device_tab.dart';

class StoryView extends StatelessWidget {
  const StoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryController());

    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.primaryGreen,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Tell My Story',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            MainTabBar(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.showOnDevice.value) {
                  return OnDeviceTab(controller: controller);
                }
                return CloudStoryTab(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}