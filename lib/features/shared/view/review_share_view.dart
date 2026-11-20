import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import 'package:lumina/features/shared/model/shared_model.dart';

class ReviewShareView extends StatelessWidget {
  const ReviewShareView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SharedMemoryController>();
    final TrustedPerson? person = Get.arguments is TrustedPerson
        ? Get.arguments as TrustedPerson
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
        title: const Text(
          'Review and share',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  child: Text(
                    person?.name.isNotEmpty == true
                        ? person!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person?.name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '@${person?.username ?? ''}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGold),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'They can',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 22, top: 4, bottom: 12),
                    child: Text(
                      'Read this page',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.cancel, size: 16, color: Colors.redAccent),
                      SizedBox(width: 6),
                      Text(
                        'They cannot',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 22, top: 4),
                    child: Text(
                      'Edit or delete this page',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 22, top: 2),
                    child: Text(
                      'See your other pages',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await controller.confirmShare();
                  Get.toNamed(AppRoutes.shareSuccess, arguments: person);
                },
                icon: const Icon(Icons.send, size: 18, color: Colors.white),
                label: const Text(
                  'Send page',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
