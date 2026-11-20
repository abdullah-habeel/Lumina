import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Keys
  static const _hybridModelKey = 'hybrid_model_name';
  static const _narrativeTemplateKey = 'narrative_template_id';
  static const _capsuleTemplateKey = 'capsule_template_id';
  static const _quoteTemplateKey = 'quote_template_id';
  static const _piiMaskingEnabledKey = 'pii_masking_enabled';
  static const _timeCapsuleEnabledKey = 'time_capsule_enabled';

  // Defaults
  static const _defaults = {
    _hybridModelKey: 'gemini-3.5-flash-lite',
    _narrativeTemplateKey: 'lumina-rich-narrative',
    _capsuleTemplateKey: 'lumina-capsule-reveal',
    _quoteTemplateKey: 'lumina-daily-quote',
    _piiMaskingEnabledKey: true,
    _timeCapsuleEnabledKey: true,
  };

  Future<void> init() async {
    await _remoteConfig.setDefaults(_defaults);

    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: kDebugMode
          ? const Duration(seconds: 0)
          : const Duration(hours: 1),
    ));

    await _remoteConfig.fetchAndActivate();

    debugPrint('REMOTE_CONFIG: hybrid_model_name = $hybridModelName');
    debugPrint('REMOTE_CONFIG: narrative_template_id = $narrativeTemplateId');
    debugPrint('REMOTE_CONFIG: capsule_template_id = $capsuleTemplateId');
    debugPrint('REMOTE_CONFIG: quote_template_id = $quoteTemplateId');
    debugPrint('REMOTE_CONFIG: pii_masking_enabled = $piiMaskingEnabled');
    debugPrint('REMOTE_CONFIG: time_capsule_enabled = $timeCapsuleEnabled');
  }

  // Getters
  String get hybridModelName => _remoteConfig.getString(_hybridModelKey);
  String get narrativeTemplateId => _remoteConfig.getString(_narrativeTemplateKey);
  String get capsuleTemplateId => _remoteConfig.getString(_capsuleTemplateKey);
  String get quoteTemplateId => _remoteConfig.getString(_quoteTemplateKey);
  bool get piiMaskingEnabled => _remoteConfig.getBool(_piiMaskingEnabledKey);
  bool get timeCapsuleEnabled => _remoteConfig.getBool(_timeCapsuleEnabledKey);
}