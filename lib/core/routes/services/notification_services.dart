import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> _tapController =
      StreamController<String?>.broadcast();

  String? _tokenOwnerUid;
  String? _registeredToken;

  Stream<String?> get onNotificationTap => _tapController.stream;

  String? pendingPayload;

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('ic_stat_notify');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true) {
        pendingPayload = launchDetails?.notificationResponse?.payload;
      }

      await _createNotificationChannels();
      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          _tapController.add(response.payload);
        },
      );
    } catch (e) {
      debugPrint('Local notification init failed: $e');
    }

    try {
      FirebaseMessaging.onMessage.listen(_showForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _tapController.add(_payloadForMessage(message));
      });
      FirebaseAuth.instance.authStateChanges().listen(_syncUserToken);
      FirebaseMessaging.instance.onTokenRefresh.listen(_saveRefreshedToken);

      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        pendingPayload = _payloadForMessage(initialMessage);
      }
    } catch (e) {
      debugPrint('Firebase Messaging init failed: $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'shared_memory_channel',
        'Shared Memories',
        description: 'Notifies when someone shares a memory with you',
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'friend_request_channel',
        'Friend Requests',
        description: 'Notifies about connection requests',
        importance: Importance.high,
      ),
    );
  }

  Future<void> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  Future<void> _syncUserToken(User? user) async {
    final previousUid = _tokenOwnerUid;
    final previousToken = _registeredToken;
    if (previousUid != null &&
        previousToken != null &&
        previousUid != user?.uid) {
      await _removeToken(previousUid, previousToken);
    }

    _tokenOwnerUid = user?.uid;
    _registeredToken = null;
    if (user == null) return;

    try {
      await requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _registeredToken = token;
        await _saveToken(user.uid, token);
      } else {
        debugPrint('FCM token unavailable for user ${user.uid}');
      }
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  Future<void> _saveRefreshedToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _tokenOwnerUid = uid;
    _registeredToken = token;
    await _saveToken(uid, token);
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FCM token save failed for user $uid: $e');
    }
  }

  Future<void> _removeToken(String uid, String token) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (snapshot.data()?['fcmToken'] == token) {
          transaction.update(userRef, {'fcmToken': FieldValue.delete()});
        }
      });
    } catch (e) {
      debugPrint('FCM token cleanup failed for user $uid: $e');
    }
  }

  void _showForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String?;
    final body = notification?.body ?? message.data['body'] as String?;
    if (title == null || body == null) return;

    final isSharedMemory = message.data['type'] == 'sharedMemory';
    unawaited(
      showNow(
        id: message.messageId?.hashCode ??
            DateTime.now().millisecondsSinceEpoch,
        title: title,
        body: body,
        payload: _payloadForMessage(message),
        channelId: isSharedMemory
            ? 'shared_memory_channel'
            : 'friend_request_channel',
        channelName: isSharedMemory ? 'Shared Memories' : 'Friend Requests',
      ),
    );
  }

  String? _payloadForMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'sharedMemory' && data['sharedMemoryId'] != null) {
      return 'shared_memory_${data['sharedMemoryId']}';
    }
    if (data['type'] == 'requestAccepted') return 'requestAccepted';
    if (data['type'] == 'timeCapsule' && data['timeCapsuleId'] != null) {
      return data['timeCapsuleId'] as String;
    }
    return null;
  }

  void handlePayload(String? payload) {
    if (payload == null) return;
    if (payload == 'daily_reminder') {
      Get.toNamed(AppRoutes.todayquestion);
    } else if (payload == 'requestAccepted') {
      Get.toNamed(AppRoutes.peopleITrust);
    } else if (payload.startsWith('shared_memory_')) {
      Get.toNamed(
        AppRoutes.sharedHome,
        arguments: {
          'sharedMemoryId': payload.substring('shared_memory_'.length),
        },
      );
    } else {
      Get.toNamed(
        AppRoutes.timeCapsuleList,
        arguments: {'openCapsuleId': payload},
      );
    }
  }

  Future<void> scheduleCapsuleUnlock({
    required int id,
    required String title,
    required DateTime unlockDate,
    String? payload,
  }) async {
    try {
      final scheduledDate = tz.TZDateTime.from(unlockDate, tz.local);

      await _plugin.zonedSchedule(
        id,
        'A Time Capsule has unlocked 🌿',
        'Your letter to yourself is ready to read.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'time_capsule_channel',
            'Time Capsule Unlocks',
            channelDescription: 'Notifies when a sealed time capsule unlocks',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('scheduleCapsuleUnlock failed: $e');
    }
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'friend_request_channel',
    String channelName = 'Friend Requests',
  }) async {
    try {
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: 'Notifies about activity in Lumina',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('showNow failed: $e');
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('cancel failed: $e');
    }
  }

  Future<void> scheduleDailyReminder() async {
    await _plugin.cancel(9999);

    final messages = [
      ('Your story is waiting 📖', 'What happened today worth remembering?'),
      (
        'Don\'t let today disappear.',
        'The best memories fade fastest. Write now.',
      ),
      ('2 minutes. That\'s all it takes.', 'Your future self will thank you.'),
      ('Something happened today.', 'Write it before sleep takes it away.'),
      ('Your book has a new chapter waiting.', 'Open it before the day ends.'),
      ('The day is almost over.', 'Capture it before it becomes a blur.'),
      ('Every day has a story.', 'What\'s yours today?'),
    ];

    final index = DateTime.now().weekday % messages.length;
    final (title, body) = messages[index];

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, 21, 0, 0);

    if (now.isAfter(scheduled)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      9999,
      title,
      body,
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Writing Reminder',
          channelDescription: 'Reminds you to write your daily chapter',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder',
    );

    debugPrint('✅ Daily reminder set for ${scheduled.toString()}');
  }
}