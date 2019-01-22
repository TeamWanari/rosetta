part of 'rosetta_generator.dart';

Class generateKeysClass(List<String> keys) {
  return Class(
    (cb) => cb
      ..name = _keysClassName
      ..fields.addAll(keys
          .map((key) => Field(
                (fb) => fb
                  ..name = ReCase(key).camelCase
                  ..type = stringType
                  ..static = true
                  ..modifier = FieldModifier.final$
                  ..assignment = literalString(key).code,
              ))
          .toList()),
  );
}
