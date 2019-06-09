part of 'rosetta_generator.dart';

Class generateHelper(
  String className,
  Stone stone,
  Map<String, List<String>> keyMap,
  List<MethodElement> interceptors,
) =>
    Class(
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
        ..methods.update((methods) {
          if (interceptors.isEmpty) {
            methods.addAll(generateSimpleGetterMethods(keyMap.keys.toList()));
          } else {
            methods.addAll(generateInterceptorMethods(interceptors));

            sortKeysByInterceptors(keyMap, interceptors)
                .forEach((method, keys) {
              if (method != null) {
                methods.addAll(generateInterceptedMethods(method, keys));
              } else {
                methods.addAll(generateSimpleGetterMethods(keys));
              }
            });
          }
        }),
    );

Method generateLoader(Stone stone) {
  var assetLoader = refer("rootBundle").property("loadString");
  var decodeJson = refer("json").property("decode");
  var assetLoaderTemplate = "${_stoneAssetsPath(stone)}/$_replaceKey.json";
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
        ...generateAssetName(),
        assetLoader
            .call([
              literalString(assetLoaderTemplate).property('replaceAll').call([literalString(_replaceKey), assetName])
            ])
            .awaited
            .assignVar(_loadJsonStr)
            .statement,
        decodeJson.call([jsonStr]).assignVar(_loadJsonMap, _mapOf(stringType, dynamicType)).statement,
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
        ..body = translations.index(key).equalTo(literalNull).conditional(literalString(''), translations.index(key)).code
        ..returns = stringType,
    );

List<Method> generateInterceptorMethods(List<MethodElement> methods) => methods
    .map((me) => Method((mb) => mb
      ..name = me.name
      ..docs.addAll(["/// Abstract Interceptor method."])
      ..types.addAll(me.typeParameters.map((tp) => refer(tp.name)).toList())
      ..requiredParameters.addAll(me.parameters
          .map((pe) => Parameter((pb) => pb
            ..name = pe.name
            ..type = refer(pe.type.displayName)))
          .toList())
      ..returns = refer(me.returnType.name)))
    .toList();

List<Method> generateSimpleGetterMethods(List<String> keys) {
  bool isFirst = true;

  return keys
      .map(
        (key) => Method(
              (mb) => mb
                ..name = ReCase(key).camelCase
                ..update((m) {
                  if (isFirst) {
                    isFirst = false;
                    m.docs.addAll(["/// Simple getter methods"]);
                  }
                })
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

List<Method> generateInterceptedMethods(
    MethodElement interceptor, List<String> keys) {
  if (interceptor.parameters.length == 1) {
    return generateSimpleInterceptedMethods(interceptor, keys);
  } else if (interceptor.parameters.length > 1) {
    return generateParametrizedInterceptedMethods(interceptor, keys);
  }
  return <Method>[];
}

List<Method> generateSimpleInterceptedMethods(
    MethodElement interceptor, List<String> keys) {
  bool isFirstMethod = true;

  return keys
      .map(
        (key) => Method(
              (mb) => mb
                ..name = ReCase(key).camelCase
                ..type = MethodType.getter
                ..update((m) {
                  if (isFirstMethod) {
                    isFirstMethod = false;
                    m.docs.addAll([
                      "/// Simple getter methods for [${interceptor.name}] interceptor."
                    ]);
                  }
                })
                ..lambda = true
                ..body = refer(interceptor.name).call([
                  translate.call([
                    refer(_keysClassName).property(ReCase(key).camelCase),
                  ]),
                ]).code
                ..returns = stringType,
            ),
      )
      .toList();
}

List<Method> generateParametrizedInterceptedMethods(
    MethodElement interceptor, List<String> keys) {
  var interceptorMethod = refer(interceptor.name);
  var methodParameters = interceptor.parameters
      .skip(1)
      .map((e) => Parameter((pb) => pb
        ..name = e.name
        ..type = refer(e.type.displayName)))
      .toList();

  var internalParameters =
      interceptor.parameters.skip(1).map((e) => refer(e.name)).toList();

  bool isFirstMethod = true;

  return keys
      .map(
        (key) => Method(
              (mb) => mb
                ..name = ReCase(key).camelCase
                ..update((m) {
                  if (isFirstMethod) {
                    isFirstMethod = false;
                    m.docs.addAll([
                      "/// Parametrized methods for [${interceptor.name}] interceptor."
                    ]);
                  }
                })
                ..requiredParameters.addAll(methodParameters)
                ..lambda = true
                ..types.addAll(interceptor.typeParameters
                    .map((tp) => refer(tp.name))
                    .toList())
                ..body = interceptorMethod
                    .call(
                      List()
                        ..add(translate.call([
                          refer(_keysClassName).property(ReCase(key).camelCase),
                        ]))
                        ..addAll(internalParameters),
                    )
                    .code
                ..returns = stringType,
            ),
      )
      .toList();
}

List<Code> generateAssetName() {
  var asset = locale.property("languageCode");
  return <Code>[
    asset.assignVar(_assetName).statement,
    const Code("if ("),
    const Code("isNotEmpty($_localeName.scriptCode)"),
    const Code(")"),
    const Code("$_assetName += '_\${$_localeName.scriptCode}';"),
    const Code("if ("),
    const Code("isNotEmpty($_localeName.countryCode)"),
    const Code(")"),
    const Code("$_assetName += '_\${$_localeName.countryCode}';"),
  ];
}
