import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/notification/controller/notification_controller.dart';
import 'package:lumina/features/notification/model/notification_model.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return Center(
            child: Text(
              "You're all caught up",
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          );
        }
        return ListView.separated(
          itemCount: controller.items.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: AppColors.borderGold.withOpacity(0.3)),
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) => controller.dismiss(item),
              child: _NotificationTile(
                item: item,
                isRead: controller.isRead(item.id),
                onTap: () => controller.handleTap(item),
              ),
            );
          },
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationItem item;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.item,
    required this.isRead,
    required this.onTap,
  });

  IconData get _icon {
    switch (item.type) {
      case AppNotificationType.timeCapsule:
        return Icons.eco;
      case AppNotificationType.friendRequest:
        return Icons.people_alt_outlined;
      case AppNotificationType.dailyPrompt:
        return Icons.edit_note;
      case AppNotificationType.requestAccepted:
        return Icons.check_circle_outline;
      case AppNotificationType.sharedMemory:
        return Icons.auto_stories_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: isRead
            ? AppColors.background
            : AppColors.borderGold.withOpacity(0.3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryGreen,
              child: Icon(_icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  if (item.time != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM, h:mm a').format(item.time!),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
