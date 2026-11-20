import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/music/model/music_model.dart';
import '../controller/music_controller.dart';

class MusicSelectionView extends StatelessWidget {
  const MusicSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MusicController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
        title: const Text(
          'Music',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Play music',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Turn background music on or off',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                value: controller.isMusicEnabled.value,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: controller.toggleMusicEnabled,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Choose a track',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...controller.availableTracks.map(
              (track) => _TrackTile(
                track: track,
                isSelected: controller.selectedTrackId.value == track.id,
                onTap: () => controller.selectTrack(track.id),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final MusicTrack track;
  final bool isSelected;
  final VoidCallback onTap;

  const _TrackTile({
    required this.track,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.music_note_rounded,
            color: AppColors.primaryGreen,
            size: 20,
          ),
        ),
        title: Text(
          track.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
            : const Icon(
                Icons.radio_button_unchecked,
                color: AppColors.textMuted,
              ),
      ),
    );
  }
}
