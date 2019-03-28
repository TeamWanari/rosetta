import 'package:code_builder/code_builder.dart';
import 'package:rosetta_generator/src/consts.dart';
import 'package:rosetta_generator/src/entities/translation.dart';
import 'package:rosetta_generator/src/utils.dart';

Class generateKeysClass(List<Translation> translations) {
  return Class(
    (cb) => cb
      ..docs.add("/// Contains the keys read from the JSON")
      ..name = strKeysClassName
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
