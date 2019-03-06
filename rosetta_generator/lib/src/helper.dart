part of 'generator.dart';

List<Class> generateHelper(
  String className,
  Stone stone,
  List<Translation> translations,
  List<Interceptor> interceptors,
) {
  List<Class> classList = [];
  var helper = Class(
    (b) => b
      ..docs.addAll([
        "/// Loads and allows access to string resources provided by the JSON",
        "/// for the specified [Locale].",
        "///",
        "/// Should be used as an abstract or mixin class for [$className].",
      ])
      ..abstract = true
      ..name = "_\$${className}Helper"
      ..fields.add(
        Field((fb) => fb
          ..name = _translationsFieldName
          ..type = _mapOf(stringType, stringType)),
      )
      ..methods.add(generateLoader(stone))
      ..methods.add(generateTranslationMethod())
      ..update((cb) {
        if (interceptors.isNotEmpty) {
          cb.methods.addAll(generateInterceptorMethods(interceptors));
        }

        Tree tree = Tree();
        var childMethods = tree.generateMethods(translations, interceptors,
            classList, refer("_\$${className}Helper"));
        cb.methods.addAll(childMethods);
        cb.fields.addAll(childMethods
            .where((child) => child.returns != stringType)
            .map((child) => Field((fieldBuilder) => fieldBuilder
              ..name = "_${child.name}"
              ..type = child.returns))
            .toList());
      }),
  );

  return [helper] + classList;
}

Method generateLoader(Stone stone) {
  var assetLoader = refer("rootBundle").property("loadString");
  var decodeJson = refer("json").property("decode");
  var assetLoaderTemplate =
      "${_stoneAssetsPath(stone)}/\${$_localeName.languageCode}.json";

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
            .call([literalString(assetLoaderTemplate)])
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

Method generateTranslationMethod() => Method(
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

List<Method> generateInterceptorMethods(List<Interceptor> interceptors) =>
    interceptors
        .map((itc) => Method(
              (mb) => mb
                ..name = itc.name
                ..docs.addAll(["/// Abstract Interceptor method."])
                ..types.addAll(itc.element.typeParameters
                    .map((tp) => refer(tp.name))
                    .toList())
                ..requiredParameters.addAll(itc.parameterList)
                ..returns = itc.returns,
            ))
        .toList();
