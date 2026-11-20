import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lumina/core/service/analystics_service.dart';

class HybridAiService {
  static const MethodChannel _channel =
      MethodChannel('com.example.lumina/hybrid_ai');

  Future<String> prepareOnDeviceModel() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'prepareOnDeviceModel',
      );
      return result?['status']?.toString() ?? 'UNKNOWN';
    } on PlatformException catch (e, stack) {
      debugPrint('HYBRID_AI: prepare failed — ${e.message}');
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'prepareOnDeviceModel failed',
        fatal: false,
      );
      return 'ERROR';
    }
  }

  Future<Map<String, dynamic>> checkOnDeviceAvailability() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'checkOnDeviceAvailability',
      );
      return {
        'available': result?['available'] ?? false,
        'status': result?['status'] ?? 'UNKNOWN',
      };
    } on PlatformException catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'checkOnDeviceAvailability failed',
        fatal: false,
      );
      return {
        'available': false,
        'status': 'ERROR: ${e.message}',
      };
    }
  }

  Future<Map<String, dynamic>> generateHybrid(String prompt) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'generateHybrid',
        {'prompt': prompt},
      );

      final inferenceSource = result?['inferenceSource'] ?? 'IN_CLOUD';

      await AnalyticsService.logMemorySaved(
        inferenceSource: inferenceSource == 'ON_DEVICE' ? 'on_device' : 'cloud',
      );

      return {
        'text': result?['text'] ?? '',
        'inferenceSource': inferenceSource,
      };
    } on PlatformException catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'generateHybrid failed',
        fatal: false,
      );
      throw Exception('Hybrid generation failed: ${e.message}');
    }
  }
}