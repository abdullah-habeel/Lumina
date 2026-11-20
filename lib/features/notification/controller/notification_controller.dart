import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/features/notification/model/notification_model.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import 'package:lumina/features/time_capsule/controller/time_capsule_list_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsController extends GetxController {
  final RxList<AppNotificationItem> items = <AppNotificationItem>[].obs;

  final RxSet<String> _readIds = <String>{}.obs;
  final RxSet<String> _dismissedIds = <String>{}.obs;

  static const _readPrefsKey = 'notif_read_ids';
  static const _dismissedPrefsKey = 'notif_dismissed_ids';

  @override
  void onInit() async {
    super.onInit();
    await _loadPersistedState();

    if (!Get.isRegistered<TimeCapsuleListController>()) {
      Get.lazyPut<TimeCapsuleListController>(
        () => TimeCapsuleListController(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<SharedController>()) {
      Get.lazyPut<SharedController>(() => SharedController(), fenix: true);
    }
    if (!Get.isRegistered<JournalController>()) {
      Get.lazyPut<JournalController>(() => JournalController(), fenix: true);
    }
    if (!Get.isRegistered<SharedMemoryController>()) {
      Get.lazyPut<SharedMemoryController>(
        () => SharedMemoryController(),
        fenix: true,
      );
    }

    _build();

    ever(Get.find<TimeCapsuleListController>().capsules, (_) => _build());

    final shared = Get.find<SharedController>();
    ever(shared.incomingRequests, (_) => _build());
    ever(shared.recentlyAcceptedRequests, (_) => _build());

    ever(Get.find<JournalController>().entries, (_) => _build());

    // Rebuild when new shared memories arrive
    ever(Get.find<SharedMemoryController>().receivedPages, (_) => _build());
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    _readIds.addAll(prefs.getStringList(_readPrefsKey) ?? []);
    _dismissedIds.addAll(prefs.getStringList(_dismissedPrefsKey) ?? []);
  }

  Future<void> _persistRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readPrefsKey, _readIds.toList());
  }

  Future<void> _persistDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dismissedPrefsKey, _dismissedIds.toList());
  }

  bool isRead(String id) => _readIds.contains(id);

  void _build() {
    final list = <AppNotificationItem>[];

    // ── Time capsules ──────────────────────────────────────────────
    if (Get.isRegistered<TimeCapsuleListController>()) {
      final capsules = Get.find<TimeCapsuleListController>().capsules;
      for (final c in capsules.where((c) => c.isUnlocked)) {
        list.add(
          AppNotificationItem(
            id: 'capsule_${c.id}',
            type: AppNotificationType.timeCapsule,
            title: 'A Time Capsule has unlocked 🌿',
            subtitle: c.title,
            time: c.unlockDate,
            payload: c.id,
          ),
        );
      }
    }

    // ── Friend requests & accepted ─────────────────────────────────
    if (Get.isRegistered<SharedController>()) {
      final shared = Get.find<SharedController>();

      for (final r in shared.incomingRequests) {
        list.add(
          AppNotificationItem(
            id: 'friend_${r.id}',
            type: AppNotificationType.friendRequest,
            title: '${r.name} wants to connect',
            subtitle: '@${r.username}',
            payload: r.id,
          ),
        );
      }

      for (final a in shared.recentlyAcceptedRequests) {
        list.add(
          AppNotificationItem(
            id: 'accepted_${a.id}',
            type: AppNotificationType.requestAccepted,
            title: '${a.friendName} accepted your request',
            subtitle: 'You can now share memories with each other',
            time: a.respondedAt,
            payload: a.id,
          ),
        );
      }
    }

    // ── Shared memories ────────────────────────────────────────────
    if (Get.isRegistered<SharedMemoryController>()) {
      final memoryCtrl = Get.find<SharedMemoryController>();

      for (final page in memoryCtrl.receivedPages) {
        // Only show unseen ones as notifications
        if (page.isSeen) continue;

        list.add(
          AppNotificationItem(
            id: 'shared_memory_${page.id}',
            type: AppNotificationType.sharedMemory,
            title: '${page.personName} shared a memory with you',
            subtitle: page.question.isNotEmpty
                ? page.question
                : 'Tap to open the shared memory',
            time: page.date,
            payload: page.id,
          ),
        );
      }
    }

    // ── Daily prompt ───────────────────────────────────────────────
    

    list.removeWhere((item) => _dismissedIds.contains(item.id));
    list.sort(
      (a, b) => (b.time ?? DateTime.now()).compareTo(a.time ?? DateTime.now()),
    );
    items.assignAll(list);
  }

  void handleTap(AppNotificationItem item) {
    if (!_readIds.contains(item.id)) {
      _readIds.add(item.id);
      _persistRead();
    }

    switch (item.type) {
      case AppNotificationType.timeCapsule:
        Get.toNamed(
          AppRoutes.timeCapsuleList,
          arguments: {'openCapsuleId': item.payload},
        );
        break;
      case AppNotificationType.friendRequest:
        Get.toNamed(AppRoutes.peopleITrust);
        break;
      case AppNotificationType.dailyPrompt:
        Get.toNamed(AppRoutes.todayquestion);
        break;
      case AppNotificationType.requestAccepted:
        Get.toNamed(AppRoutes.peopleITrust);
        break;
      case AppNotificationType.sharedMemory:
        Get.toNamed(
          AppRoutes.sharedHome,
          arguments: {'sharedMemoryId': item.payload},
        );
        break;
    }
  }

  void dismiss(AppNotificationItem item) {
    _dismissedIds.add(item.id);
    items.removeWhere((i) => i.id == item.id);
    _persistDismissed();
  }
}
