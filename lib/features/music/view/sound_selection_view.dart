import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import '../controller/sound_effects_controller.dart';

class SoundSelectionView extends StatelessWidget {
  const SoundSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SoundEffectsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
        title: const Text(
          'Sound',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Play sound effects',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Turn app sound effects on or off',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                value: controller.isSoundEffectsEnabled.value,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: controller.toggleSoundEffects,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
