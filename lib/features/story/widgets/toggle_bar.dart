import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/story/controller/story_controller.dart';

class ToggleBar extends StatelessWidget {
  final StoryController controller;
  const ToggleBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                ToggleOption(
                  label: 'Without AI Patterns',
                  isSelected: !controller.showRich.value,
                  onTap: () {
                    if (controller.showRich.value) controller.toggleMode();
                  },
                ),
                ToggleOption(
                  label: 'With AI Patterns',
                  isSelected: controller.showRich.value,
                  onTap: () {
                    if (!controller.showRich.value) controller.toggleMode();
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

class ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ToggleOption({
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  isSelected ? Colors.white : AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}