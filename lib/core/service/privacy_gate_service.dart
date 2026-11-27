import 'package:shared_preferences/shared_preferences.dart';

enum PrivacyChoice { notAsked, onDeviceOnly, cloudEnabled }

class PrivacyGateService {
  static final PrivacyGateService _instance = PrivacyGateService._internal();
  factory PrivacyGateService() => _instance;
  PrivacyGateService._internal();

  static const _key = 'privacy_gate_choice';

  Future<PrivacyChoice> getChoice() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    switch (value) {
      case 'onDeviceOnly':
        return PrivacyChoice.onDeviceOnly;
      case 'cloudEnabled':
        return PrivacyChoice.cloudEnabled;
      default:
        return PrivacyChoice.notAsked;
    }
  }

  Future<void> saveChoice(PrivacyChoice choice) async {
    final prefs = await SharedPreferences.getInstance();
    switch (choice) {
      case PrivacyChoice.onDeviceOnly:
        await prefs.setString(_key, 'onDeviceOnly');
        break;
      case PrivacyChoice.cloudEnabled:
        await prefs.setString(_key, 'cloudEnabled');
        break;
      case PrivacyChoice.notAsked:
        await prefs.remove(_key);
        break;
    }
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}