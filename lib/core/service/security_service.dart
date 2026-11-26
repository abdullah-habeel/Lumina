import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/core/service/hybrid_ai_service.dart';
import 'package:lumina/core/service/remote_config_service.dart';

class SecurityService {
  final RemoteConfigService _remoteConfig;
  final HybridAiService _hybridAi;

  SecurityService({
    RemoteConfigService? remoteConfig,
    HybridAiService? hybridAi,
  })  : _remoteConfig = remoteConfig ?? RemoteConfigService(),
        _hybridAi = hybridAi ?? HybridAiService();

  // ── MASK ───────────────────────────────────────────────────
  Future<({String maskedText, Map<String, String> entityMap})> maskText(
      String raw) async {
    if (!_remoteConfig.piiMaskingEnabled) {
      debugPrint('SECURITY: PII masking disabled via Remote Config');
      return (maskedText: raw, entityMap: <String, String>{});
    }

    try {
      final names = await _extractNamesOnDevice(raw);

      if (names.isNotEmpty) {
        debugPrint('SECURITY: on-device NER found ${names.length} names: $names');
        return _maskWithNames(raw, names);
      } else {
        debugPrint('SECURITY: on-device NER found no names');
        return (maskedText: raw, entityMap: <String, String>{});
      }
    } catch (e, stack) {
      debugPrint('SECURITY: on-device NER failed — falling back to regex: $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack,
        reason: 'SecurityService NER fallback to regex',
        fatal: false,
      );
      return _regexMask(raw);
    }
  }

  // ── APPLY EXISTING MAP ─────────────────────────────────────
  String applyExistingMap(String raw, Map<String, String> entityMap) {
    if (!_remoteConfig.piiMaskingEnabled || entityMap.isEmpty) return raw;

    final nameToToken = <String, String>{
      for (final entry in entityMap.entries) entry.value: entry.key
    };

    String result = raw;
    for (final entry in nameToToken.entries) {
      result = result.replaceAll(
        RegExp(RegExp.escape(entry.key), caseSensitive: false),
        entry.value,
      );
    }
    return result;
  }

  // ── RESTORE ────────────────────────────────────────────────
  String restoreText(String masked, Map<String, String> entityMap) {
    if (!_remoteConfig.piiMaskingEnabled || entityMap.isEmpty) return masked;

    String result = masked;
    for (final entry in entityMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    debugPrint('SECURITY: restored ${entityMap.length} entities in response');
    return result;
  }

  // ── PRIVATE: ON-DEVICE NAME EXTRACTION ────────────────────
  Future<List<String>> _extractNamesOnDevice(String raw) async {
    final prompt = '''
You are a named entity recognition engine. Your ONLY job is to find person names in the text below.

STRICT RULES:
- Return ONLY a valid JSON array of strings. Nothing else.
- Include ONLY real person names (first names, last names, nicknames).
- Do NOT include: cities, countries, brands, days, months, religions, emotions, or any non-person words.
- Do NOT include pronouns like "he", "she", "they", "I".
- If no person names exist, return an empty array: []
- No explanation. No markdown. No backticks. Just the JSON array.

Examples:
Text: "I went to Ahmed's house. Sara called me later."
Output: ["Ahmed", "Sara"]

Text: "It was a quiet Monday in Lahore. I felt peaceful."
Output: []

Text: "Uncle Tariq and my friend Zara came over."
Output: ["Tariq", "Zara"]

Now analyze this text:
$raw
''';

    final result = await _hybridAi.generateHybrid(prompt);
    final text = (result['text'] as String).trim();
    final inferenceSource = result['inferenceSource'] as String;

    debugPrint('SECURITY: NER inference source = $inferenceSource');

    return _parseNameList(text);
  }

  // ── PRIVATE: MASK WITH KNOWN NAMES ────────────────────────
  ({String maskedText, Map<String, String> entityMap}) _maskWithNames(
      String raw, List<String> names) {
    final Map<String, String> entityMap = <String, String>{};
    int counter = 1;

    String result = raw;
    for (final name in names) {
      final token = '[Person_$counter]';
      counter++;
      entityMap[token] = name;

      result = result.replaceAll(
        RegExp(RegExp.escape(name), caseSensitive: false),
        token,
      );
      debugPrint('SECURITY: masked "$name" → "$token"');
    }

    return (maskedText: result, entityMap: entityMap);
  }

  // ── PRIVATE: REGEX FALLBACK ────────────────────────────────
  ({String maskedText, Map<String, String> entityMap}) _regexMask(String raw) {
    debugPrint('SECURITY: using regex fallback masking');

    final Map<String, String> entityMap = <String, String>{};
    final Map<String, String> nameToToken = <String, String>{};
    int counter = 1;

    final wordRegex = RegExp(r'\b([A-Z][a-z]{1,})\b');

    final result = raw.replaceAllMapped(wordRegex, (match) {
      final word = match.group(1)!;
      if (_isCommonWord(word)) return word;
      if (nameToToken.containsKey(word)) return nameToToken[word]!;

      final token = '[Person_$counter]';
      counter++;
      nameToToken[word] = token;
      entityMap[token] = word;
      debugPrint('SECURITY: regex masked "$word" → "$token"');
      return token;
    });

    debugPrint('SECURITY: regex masked ${entityMap.length} entities');
    return (maskedText: result, entityMap: entityMap);
  }

  // ── PRIVATE: PARSE NAME LIST ───────────────────────────────
  List<String> _parseNameList(String raw) {
    try {
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      if (cleaned == '[]') return <String>[];

      final inner = cleaned
          .replaceAll('[', '')
          .replaceAll(']', '');

      if (inner.trim().isEmpty) return <String>[];

      return inner
          .split(',')
          .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('SECURITY: name list parse failed — $e');
      return <String>[];
    }
  }

  // ── PRIVATE: COMMON WORD FILTER (regex fallback only) ─────
  bool _isCommonWord(String word) {
    const common = <String>{
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
      'I', 'The', 'A', 'An', 'This', 'That', 'My', 'We', 'He', 'She',
      'They', 'It', 'His', 'Her', 'Our', 'Their', 'Its', 'You', 'Your',
      'God', 'Allah', 'Life', 'Time', 'Today', 'Yesterday', 'Tomorrow',
      'Home', 'Work', 'School', 'College', 'University', 'Hospital',
      'Morning', 'Evening', 'Night', 'Afternoon', 'Pakistan', 'Lahore',
      'Karachi', 'Islamabad', 'Faisalabad', 'Ramadan', 'Eid',
      'Love', 'Fear', 'Joy', 'Pain', 'Hope', 'Peace', 'Growth', 'Loss',
    };
    return common.contains(word);
  }
}