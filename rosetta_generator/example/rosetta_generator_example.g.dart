// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rosetta_generator_example.dart';

// **************************************************************************
// RosettaStoneGenerator
// **************************************************************************

/// A factory for a set of localized resources of type Translation, to be loaded by a
/// [Localizations] widget.
class _$TranslationDelegate extends LocalizationsDelegate<Translation> {
  /// Whether the the given [locale.languageCode] code has a JSON associated with it.
  @override
  bool isSupported(Locale locale) =>
      const <String>[].contains(locale.languageCode);

  /// Returns true if the resources for this delegate should be loaded
  /// again by calling the [load] method.
  @override
  bool shouldReload(LocalizationsDelegate<Translation> old) => false;

  /// Loads the JSON associated with the given [locale] using [Strings].
  @override
  Future<Translation> load(Locale locale) async {
    final Translation translation = Translation();
    await translation.load(locale);
    return translation;
  }
}

/// Contains the keys read from the JSON
class TranslationKeys {}

/// Loads and allows access to string resources provided by the JSON
/// for the specified [Locale].
///
/// Should be used as an abstract or mixin class for [Translation].
abstract class _$TranslationHelper {
  /// Contains the translated strings for each key.
  Map<String, String> _translations;

  /// Contains the string translations or interceptor/// methods for each key.
  Map<String, dynamic> _resolutions;

  /// Loads and decodes the JSON associated with the given [locale].
  Future<void> load(Locale locale) async {
    final String jsonStr =
        await rootBundle.loadString('i18n/${locale.languageCode}.json');
    final Map jsonMap = json.decode(jsonStr);
    _translations = jsonMap.map<String, String>(
        (dynamic key, dynamic value) => MapEntry<String, String>(key, value));
    _resolutions = <String, dynamic>{};
  }

  /// Returns the requested string resource associated with the given [key].
  String _translate(String key) => _translations[key];

  /// Returns the requested processed string resource associated with the given [key].
  dynamic resolve(String key) => _resolutions[key];
}
