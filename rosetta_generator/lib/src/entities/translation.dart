import 'package:recase/recase.dart';

///Represents a single translation, read from the JSON.
///
///Contains the key and the translation String for each language.
///
///The tieredKey list holds the names of the Nodes or variables
///which will be generated.

class Translation {
  String key;
  List<String> translations;
  List<String> groupedKey;
  String separator;

  String get keyVariable {
    if (separator != null) {
      return key
              .split(separator)
              .map((part) => ReCase(part).camelCase)
              .toList()
              .join("\$") +
          "\$";
    } else {
      return ReCase(key).camelCase + "\$";
    }
  }

  Translation({String key, this.translations, this.separator}) {
    if (key.contains(".") && separator != ".") {
      throw Exception("The key must not contain dots! Invalid key: ${key}");
    }

    this.key = key;
    groupedKey =
        List.of((this.separator == null ? [key] : key.split(this.separator)));
  }
}

List<String> keysOf(List<Translation> translations) {
  return translations.map((translation) => translation.key).toList();
}
