part of 'rosetta_generator.dart';

Class generateHelper(Element element, String path, List<String> keys) {
  return Class(
    (b) => b
      ..abstract = true
      ..name = "_\$${element.name}Helper"
      ..fields.add(Field((fb) => fb
        ..name = "_translations"
        ..type = refer("Map<String, String>")))
      ..methods.add(generateLoader(path))
      ..methods.add(generateTranslationMethod())
      ..methods.addAll(generateKeyTranslationMethods(keys)),
  );
}

Method generateLoader(String path) {
  return Method(
    (mb) => mb
      ..name = "load"
      ..returns = refer("Future<void>")
      ..modifier = MethodModifier.async
      ..requiredParameters.add(
        Parameter((p) => p
          ..name = "locale"
          ..type = refer('Locale')),
      )
      ..body = Block(
        (bb) => bb
          ..statements.add(
            Code("var jsonStr = await rootBundle.loadString(\"" +
                "$path/\${locale.languageCode}.json\");"),
          )
          ..statements.add(
            Code("Map<String, dynamic> jsonMap = json.decode(jsonStr);"),
          )
          ..statements.add(
            Code("_translations = jsonMap.map<String, String>((key, value) =>" +
                " MapEntry(key, value as String));"),
          ),
      ),
  );
}

Method generateTranslationMethod() {
  return Method(
    (mb) => mb
      ..name = "_translate"
      ..lambda = true
      ..requiredParameters.add(
        Parameter(
          (pb) => pb
            ..name = "key"
            ..named = true
            ..type = refer("String"),
        ),
      )
      ..body = Code("_translations[key]")
      ..returns = refer("String"),
  );
}

List<Method> generateKeyTranslationMethods(List<String> keys) {
  return keys
      .map((key) => Method((mb) => mb
        ..name = ReCase(key).camelCase
        ..type = MethodType.getter
        ..lambda = true
        ..body = Code("_translate(_\$Keys.${ReCase(key).camelCase})")
        ..returns = refer("String")))
      .toList();
}
