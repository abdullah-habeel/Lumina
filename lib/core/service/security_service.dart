import 'consent_service.dart';

class MaskedPayload {
  final String maskedText;
  final Map<String, String> entityMap;

  MaskedPayload({
    required this.maskedText,
    required this.entityMap,
  });
}

class SecurityService {
  final ConsentService _consentService = ConsentService();

  static const Set<String> _excludedWords = {
    'You',
    'I',
    'The',
    'A',
    'An',
    'In',
    'On',
    'At',
    'To',
    'For',
    'And',
    'We',
    'Who',
    'When',
    'Where',
    'Why',
    'How',
  };

  Future<bool> hasCloudConsent() async {
    return _consentService.hasConsented();
  }

  /// Replaces capitalized names/entities locally with [Person_1], [Person_2], etc.
  MaskedPayload maskText(String text) {
    var maskedText = text;
    final Map<String, String> entityMap = {};
    final nameRegex = RegExp(r'\b[A-Z][a-z]+\b');

    int count = 1;
    for (final match in nameRegex.allMatches(text)) {
      final word = match.group(0)!;
      if (_excludedWords.contains(word)) continue;

      if (!entityMap.containsValue(word)) {
        final placeholder = '[Person_$count]';
        entityMap[placeholder] = word;
        maskedText = maskedText.replaceAll(word, placeholder);
        count++;
      }
    }

    return MaskedPayload(maskedText: maskedText, entityMap: entityMap);
  }

  /// Applies an existing entityMap so placeholders stay consistent across blocks.
  String applyExistingMap(String text, Map<String, String> entityMap) {
    var updated = text;
    entityMap.forEach((placeholder, originalWord) {
      updated = updated.replaceAll(originalWord, placeholder);
    });
    return updated;
  }

  /// Restores original names locally after receiving output from the cloud.
  String restoreText(String text, Map<String, String> entityMap) {
    var restored = text;
    entityMap.forEach((placeholder, originalWord) {
      restored = restored.replaceAll(placeholder, originalWord);
    });
    return restored;
  }
}