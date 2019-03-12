import 'package:recase/recase.dart';
import 'package:rosetta_generator/src/consts.dart';

class Translation {
  String key;
  List<String> translations;
  List<String> tieredKey;

  String get keyVariable =>
      key
          .split(chrKeyDivider)
          .map((part) => ReCase(part).camelCase)
          .toList()
          .join("\$") +
      "\$";

  Translation({String key, this.translations}) {
    this.key = key;
    tieredKey = List.of(key.split(chrKeyDivider));
  }
}

List<String> keysOf(List<Translation> translations) {
  return translations.map((translation) => translation.key).toList();
}
