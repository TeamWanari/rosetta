part of 'rosetta_generator.dart';

Class generateHelper(Element element, String path, List<String> keys) {
  return Class(
    (b) => b
      ..docs.addAll([
        "/// Loads and allows access to string resources provided by the JSON",
        "/// for the specified [Locale].",
        "///",
        "/// Should be used as a mixin class for [${element.name}].",
      ])
      ..abstract = true
      ..name = "_\$${element.name}Helper"
      ..fields.add(
        Field((fb) => fb
          ..name = _translationsFieldName
          ..type = _mapOf(stringType, stringType)),
      )
      ..methods.add(generateLoader(path))
      ..methods.add(generateTranslationMethod())
      ..methods.addAll(generateKeyTranslationMethods(keys)),
  );
}

Method generateLoader(String path) {
  var assetLoader = refer("rootBundle").property("loadString");
  var decodeJson = refer("json").property("decode");

  return Method(
    (mb) => mb
      ..docs.addAll([
        "/// Loads and decodes the JSON associated with the given [locale].",
      ])
      ..name = _loadMethodName
      ..returns = _futureOf("void")
      ..modifier = MethodModifier.async
      ..requiredParameters.add(localeParameter)
      ..body = Block.of([
        assetLoader
            .call([literalString("$path/\${$_localeName.languageCode}.json")])
            .awaited
            .assignVar(_loadJsonStr)
            .statement,
        decodeJson
            .call([jsonStr])
            .assignVar(_loadJsonMap, _mapOf(stringType, dynamicType))
            .statement,
        translations
            .assign(
              jsonMap.property("map<String, String>").call([
                refer("(key, value) => MapEntry(key, value as String)"),
              ]),
            )
            .statement,
      ]),
  );
}

Method generateTranslationMethod() {
  return Method(
    (mb) => mb
      ..docs.addAll([
        "/// Returns the requested string resource associated with the given [key].",
      ])
      ..name = _translateMethodName
      ..lambda = true
      ..requiredParameters.add(
        Parameter((pb) => pb
          ..name = _keyName
          ..named = true
          ..type = stringType),
      )
      ..body = translations.index(key).code
      ..returns = stringType,
  );
}

List<Method> generateKeyTranslationMethods(List<String> keys) {
  return keys
      .map(
        (key) => Method(
              (mb) => mb
                ..name = ReCase(key).camelCase
                ..type = MethodType.getter
                ..lambda = true
                ..body = translate.call([
                  refer(_keysClassName).property(ReCase(key).camelCase),
                ]).code
                ..returns = stringType,
            ),
      )
      .toList();
}
