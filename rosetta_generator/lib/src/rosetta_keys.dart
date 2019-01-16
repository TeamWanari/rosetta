part of 'rosetta_generator.dart';

Class generateKeysClass(List<String> keys) {
  return Class(
    (cb) => cb
      ..name = "_\$Keys"
      ..fields.addAll(keys
          .map((key) => Field(
                (fb) => fb
                  ..name = ReCase(key).camelCase
                  ..type = refer("String")
                  ..static = true
                  ..modifier = FieldModifier.final$
                  ..assignment = Code("\"$key\""),
              ))
          .toList()),
  );
}
