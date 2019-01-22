part of 'rosetta_generator.dart';

Class generateDelegate(String className, List<String> languages) {
  var delegateClassName = "${className}Delegate";

  return Class((builder) => builder
    ..name = '_\$$delegateClassName'
    ..extend = _localizationDelegateOf(className)
    ..methods.addAll(_delegateMethods(className, languages)));
}

List<Method> _delegateMethods(String className, List<String> languages) => [
      _isSupported(languages),
      _shouldReload(className),
      _load(className),
    ];

Method _isSupported(List<String> supportedLanguages) => Method(
      (builder) => builder
        ..annotations.add(overrideAnnotation)
        ..returns = boolType
        ..name = 'isSupported'
        ..requiredParameters.add(localeParameter)
        ..lambda = true
        ..body = literalConstList(supportedLanguages)
            .property("contains")
            .call([locale.property("languageCode")]).code,
    );

Method _shouldReload(String className) {
  return Method((mb) => mb
    ..annotations.add(overrideAnnotation)
    ..returns = boolType
    ..name = 'shouldReload'
    ..requiredParameters.add(Parameter(
      (param) => param
        ..name = 'old'
        ..type = _localizationDelegateOf(className),
    ))
    ..lambda = true
    ..body = literalFalse.code);
}

Method _load(String className) {
  var fieldName = ReCase(className).camelCase;
  var field = refer(fieldName);

  return Method(
    (mb) => mb
      ..annotations.add(overrideAnnotation)
      ..returns = _futureOf(className)
      ..name = 'load'
      ..modifier = MethodModifier.async
      ..requiredParameters.add(localeParameter)
      ..body = Block.of([
        refer(className).newInstance([]).assignVar(fieldName).statement,
        field.property(_loadMethodName).call([locale]).awaited.statement,
        field.returned.statement,
      ]),
  );
}
