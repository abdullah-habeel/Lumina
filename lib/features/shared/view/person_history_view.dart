import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/shared/model/shared_model.dart';
import '../controller/shared_memory_controller.dart';

class PersonHistoryView extends StatelessWidget {
  const PersonHistoryView({super.key});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final memoryController = Get.find<SharedMemoryController>();
    final TrustedPerson? person = Get.arguments is TrustedPerson
        ? Get.arguments as TrustedPerson
        : null;

    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primaryGreen),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            final pages = person != null
                ? memoryController.pagesSharedWith(person.id)
                : <SharedPage>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Profile header ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(0.1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.borderGold.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColors.borderGold.withOpacity(0.6),
                        width: 0.8,
                      ),
                      color: AppColors.cardBackground,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderGold,
                              width: 1.2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primaryGreen.withOpacity(
                              0.08,
                            ),
                            backgroundImage:
                                (person?.photoUrl != null &&
                                    person!.photoUrl!.isNotEmpty)
                                ? NetworkImage(person.photoUrl!)
                                : null,
                            child:
                                (person?.photoUrl == null ||
                                    person!.photoUrl!.isEmpty)
                                ? Text(
                                    person?.name.isNotEmpty == true
                                        ? person!.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                person?.name ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.alternate_email,
                                    size: 11,
                                    color: AppColors.borderGold.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    person?.username ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_stories_outlined,
                                    size: 11,
                                    color: AppColors.borderGold.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${pages.length} ${pages.length == 1 ? 'memory' : 'memories'} shared',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Section divider ──
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.borderGold.withOpacity(0.5),
                        thickness: 0.8,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '✦  Shared Memories  ✦',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: AppColors.borderGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.borderGold.withOpacity(0.5),
                        thickness: 0.8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Memory list ──
                Expanded(
                  child: pages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_stories_outlined,
                                size: 40,
                                color: AppColors.borderGold.withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No memories shared yet',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: pages.length,
                          itemBuilder: (context, index) {
                            final p = pages[index];
                            final dateText =
                                '${_months[p.date.month - 1]} ${p.date.day}, ${p.date.year}';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () => Get.toNamed(
                                  AppRoutes.receivedSharedPage,
                                  arguments: p,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(0.5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.primaryGreen.withOpacity(
                                        0.85,
                                      ),
                                      width: 0.1,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(11),
                                      border: Border.all(
                                        color: AppColors.borderGold.withOpacity(
                                          0.6,
                                        ),
                                        width: 0.8,
                                      ),
                                      color: AppColors.cardBackground,
                                    ),
                                    child: Row(
                                      children: [
                                        // direction icon
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.borderGold
                                                  .withOpacity(0.5),
                                              width: 1,
                                            ),
                                            color: AppColors.primaryGreen
                                                .withOpacity(0.06),
                                          ),
                                          child: Icon(
                                            p.direction == SharedDirection.sent
                                                ? Icons.upload_outlined
                                                : Icons.download_outlined,
                                            size: 16,
                                            color: AppColors.primaryGreen
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.question,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13.5,
                                                  color: AppColors.textPrimary,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .calendar_today_outlined,
                                                    size: 10,
                                                    color: AppColors.borderGold
                                                        .withOpacity(0.9),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    dateText,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          AppColors.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: AppColors.borderGold
                                              .withOpacity(0.6),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
