import 'package:lumina/core/service/analystics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentService {
  static const _key = 'ai_cloud_fallback_consent';

  Future<bool> hasConsented() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> saveConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);

    if (value) {
      await AnalyticsService.logConsentGranted();
    } else {
      await AnalyticsService.logConsentDenied();
    }
  }
}