import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_background.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import 'package:lumina/features/shared/model/shared_model.dart';
import 'package:lumina/features/shared/widgets/dashed_action_button.dart';
import '../controller/shared_controller.dart';
import '../widgets/trust_person_tile.dart';

class PeopleITrustView extends StatelessWidget {
  const PeopleITrustView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SharedController>();
    final memoryController = Get.find<SharedMemoryController>();

    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primaryGreen),
          title: Builder(
            builder: (context) => Text(
              'People I trust',
              style: TextStyle(
                color: DaylightAppColors.bookTitleText(
                  DaylightTime.of(context),
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: Builder(
          builder: (context) {
            final hour = DaylightTime.of(context);
            final cardBg = DaylightAppColors.cardBackground(hour);
            final border = DaylightAppColors.borderGold(hour);
            final accent = DaylightAppColors.accentGold(hour);
            final textColor = DaylightAppColors.cardText(hour);
            final subtextColor = DaylightAppColors.cardSubtext(hour);
            final headingColor = DaylightAppColors.headingText(hour);

            return Obx(
              () => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (controller.incomingRequests.isNotEmpty) ...[
                    Text(
                      'Requests',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: headingColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.incomingRequests.map(
                      (req) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: accent.withOpacity(0.1),
                                  child: Text(
                                    req.name[0].toUpperCase(),
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        'wants to connect with you',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        controller.acceptRequest(req.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                    ),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        controller.declineRequest(req.id),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: border),
                                    ),
                                    child: Text(
                                      'Decline',
                                      style: TextStyle(color: subtextColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Section heading ──
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: border.withOpacity(0.5),
                          thickness: 0.8,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '✦  Connected  ✦',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 2,
                            color: border,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: border.withOpacity(0.5),
                          thickness: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Vintage tiles ──
                  ...controller.trustedPeople.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _VintageTrustTile(
                        person: p,
                        memoryCount: memoryController.sharedMemoriesCountFor(
                          p.id,
                        ),
                        onTap: () =>
                            Get.toNamed(AppRoutes.personHistory, arguments: p),
                        onRemove: () =>
                            _showRemoveConfirmation(context, controller, p),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  DoubleBorderActionButton(
                    label: 'Add someone',
                    onPressed: () => Get.toNamed(AppRoutes.addSomeone),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showRemoveConfirmation(
    BuildContext context,
    SharedController controller,
    TrustedPerson person,
  ) {
    final hour = DaylightTime.of(context);
    final cardBg = DaylightAppColors.cardBackground(hour);
    final textColor = DaylightAppColors.cardText(hour);
    final subtextColor = DaylightAppColors.cardSubtext(hour);

    Get.dialog(
      AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Remove connection?',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to remove ${person.name} from People I Trust?',
          style: TextStyle(color: subtextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: subtextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeFriend(person.id, person.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ── Vintage Tile ──────────────────────────────────────────────────────────────

class _VintageTrustTile extends StatelessWidget {
  final TrustedPerson person;
  final int memoryCount;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _VintageTrustTile({
    required this.person,
    required this.memoryCount,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final cardBg = DaylightAppColors.cardBackground(hour);
    final border = DaylightAppColors.borderGold(hour);
    final accent = DaylightAppColors.accentGold(hour);
    final textColor = DaylightAppColors.cardText(hour);
    final subtextColor = DaylightAppColors.cardSubtext(hour);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // ── Outer decorative border ──
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border.withOpacity(0.35), width: 1),
            ),
            padding: const EdgeInsets.all(0.5),
            child: Container(
              // ── Inner border ──
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: border.withOpacity(0.6), width: 0.8),
                color: cardBg,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // ── Avatar with aged ring ──
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: border, width: 1.2),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: accent.withOpacity(0.08),
                      backgroundImage:
                          (person.photoUrl != null &&
                              person.photoUrl!.isNotEmpty)
                          ? NetworkImage(person.photoUrl!)
                          : null,
                      child:
                          (person.photoUrl == null || person.photoUrl!.isEmpty)
                          ? Text(
                              person.name[0].toUpperCase(),
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ── Name + memory badge ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: textColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: 12,
                              color: border.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$memoryCount shared ${memoryCount == 1 ? 'memory' : 'memories'}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: subtextColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Corner ornament + menu ──
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: border.withOpacity(0.7),
                      size: 20,
                    ),
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: border.withOpacity(0.3)),
                    ),
                    onSelected: (value) {
                      if (value == 'remove') onRemove();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_remove_outlined,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Remove connection',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
