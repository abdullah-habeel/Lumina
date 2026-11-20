import 'package:get/get.dart';
import 'en_us.dart';
import 'de_de.dart';
import 'fr_fr.dart';
import 'es_es.dart';
import 'it_it.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'de_DE': deDE,
    'fr_FR': frFR,
    'es_ES': esES,
    'it_IT': itIT,
  };
}