import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/story/controller/story_controller.dart';

class MainTabBar extends StatelessWidget {
  final StoryController controller;
  const MainTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                MainTabOption(
                  label: '🔒 On-Device',
                  isSelected: controller.showOnDevice.value,
                  onTap: controller.switchToOnDevice,
                ),
                MainTabOption(
                  label: '☁️ Cloud Story',
                  isSelected: !controller.showOnDevice.value,
                  onTap: controller.switchToCloud,
                ),
              ],
            ),
          ),
        ));
  }
}

class MainTabOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MainTabOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}