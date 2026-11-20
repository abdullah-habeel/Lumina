import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<void> saveDeviceInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String deviceName = 'Unknown';

      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        deviceName = '${info.manufacturer} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        deviceName = info.utsname.machine;
      }

      final language = ui.PlatformDispatcher.instance.locale.languageCode;
      final timezone = DateTime.now().timeZoneName;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('device_info')
          .doc('latest')
          .set({
        'deviceName': deviceName,
        'language': language,
        'timezone': timezone,
        'platform': Platform.isAndroid ? 'Android' : 'iOS',
        'lastOpenedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Device info saved');
    } catch (e) {
      debugPrint('❌ DeviceInfoService error: $e');
    }
  }
}