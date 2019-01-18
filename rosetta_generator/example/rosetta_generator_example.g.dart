// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rosetta_generator_example.dart';

// **************************************************************************
// Generator: RosettaStoneBuilder
// **************************************************************************

class _$TranslationDelegate extends LocalizationsDelegate<Translation> {
  @override
  bool isSupported(Locale locale) => ["en"].contains(locale.languageCode);
  @override
  bool shouldReload(LocalizationsDelegate<Translation> old) => false;
  @override
  Future<Translation> load(Locale locale) async {
    var translations = Translation();
    await translations.load(locale);
    return translations;
  }
}

class _$Keys {
  static final String helloThere = "hello_there";

  static final String seeYouSoon = "see_you_soon";
}

abstract class _$TranslationHelper {
  Map<String, String> _translations;

  Future<void> load(Locale locale) async {
    var jsonStr =
        await rootBundle.loadString("i18n/${locale.languageCode}.json");
    Map<String, dynamic> jsonMap = json.decode(jsonStr);
    _translations = jsonMap
        .map<String, String>((key, value) => MapEntry(key, value as String));
  }

  String _translate(String key) => _translations[key];
  String get helloThere => _translate(_$Keys.helloThere);
  String get seeYouSoon => _translate(_$Keys.seeYouSoon);
}
