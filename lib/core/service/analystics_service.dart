import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  static Future<void> logMemorySaved({required String inferenceSource}) async {
    await _analytics.logEvent(
      name: 'memory_saved',
      parameters: {'inference_source': inferenceSource}, // 'on_device' | 'cloud'
    );
  }

  static Future<void> logNarrativeGenerated() async {
    await _analytics.logEvent(name: 'narrative_generated');
  }

  static Future<void> logCapsuleLocked() async {
    await _analytics.logEvent(name: 'capsule_locked');
  }

  static Future<void> logCapsuleRevealed() async {
    await _analytics.logEvent(name: 'capsule_revealed');
  }

  static Future<void> logConsentGranted() async {
    await _analytics.logEvent(name: 'consent_granted');
  }

  static Future<void> logConsentDenied() async {
    await _analytics.logEvent(name: 'consent_denied');
  }
}