enum AppNotificationType {
  timeCapsule,
  friendRequest,
  dailyPrompt,
  requestAccepted,
  sharedMemory, // ← new
}

class AppNotificationItem {
  final String id;
  final AppNotificationType type;
  final String title;
  final String subtitle;
  final DateTime? time;
  final String? payload;

  AppNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.time,
    this.payload,
  });
}