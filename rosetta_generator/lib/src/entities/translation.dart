part of '../generator.dart';

class Translation {
  String key;
  List<String> translations;
  List<String> tieredKey;

  String get keyVariable =>
      key.split(_keyDividerChar).map((part) => ReCase(part).camelCase).toList().join("\$") +
      "\$";

  Translation({String key, this.translations}) {
    this.key = key;
    tieredKey = List.of(key.split(_keyDividerChar));
  }
}

List<String> keysOf(List<Translation> translations) {
  return translations.map((translation) => translation.key).toList();
}
