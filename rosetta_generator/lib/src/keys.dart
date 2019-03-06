part of 'generator.dart';

Class generateKeysClass(List<Translation> translations) {
  return Class(
    (cb) => cb
      ..docs.add("/// Contains the keys read from the JSON")
      ..name = _keysClassName
      ..fields.addAll(translations
          .map((translation) => Field(
                (fb) => fb
                  ..name = translation.keyVariable
                  ..type = stringType
                  ..static = true
                  ..modifier = FieldModifier.final$
                  ..assignment = literalString(translation.key).code,
              ))
          .toList()),
  );
}
