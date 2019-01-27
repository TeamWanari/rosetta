part of 'rosetta_generator.dart';

Class generateHelper(String className, String path,
    Map<String, List<String>> keyMap, List<MethodElement> interceptors) {
  return Class(
    (b) => b
      ..docs.addAll([
        "/// Loads and allows access to string resources provided by the JSON",
        "/// for the specified [Locale].",
        "///",
        "/// Should be used as a mixin class for [$className}].",
      ])
      ..abstract = true
      ..name = "_\$${className}Helper"
      ..fields.add(
        Field((fb) => fb
          ..name = _translationsFieldName
          ..type = _mapOf(stringType, stringType)),
      )
      ..methods.add(generateLoader(path))
      ..methods.add(generateTranslationMethod())
      ..methods.update((methods) {
        if (interceptors.isEmpty) {
          methods.addAll(generateSimpleGetterMethods(keyMap.keys.toList()));
        } else {
          methods.addAll(generateInterceptorMethods(interceptors));

          sortKeysByInterceptors(keyMap, interceptors).forEach((method, keys) {
            if (method != null) {
              methods.addAll(generateInterceptedMethods(method, keys));
            } else {
              methods.addAll(generateSimpleGetterMethods(keys));
            }
          });
        }
      }),
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
    return generateSimpleInterceptedMethods(refer(interceptor.name), keys);
  } else if (interceptor.parameters.length > 1) {
    return generateParametrizedInterceptedMethods(interceptor, keys);
  }
  return <Method>[];
}

List<Method> generateSimpleInterceptedMethods(
    Reference interceptor, List<String> keys) {
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
                      "/// Simple getter methods for [${interceptor.code.toString()}] interceptor."
                    ]);
                  }
                })
                ..lambda = true
                ..body = interceptor.call([
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
