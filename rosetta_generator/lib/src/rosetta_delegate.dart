part of 'rosetta_generator.dart';

Class generateDelegate(String className, List<String> languages) {
  var delegateClassName = "${className}Delegate";

  return Class((builder) => builder
    ..name = '_\$$delegateClassName'
    ..extend = _delegateReference(className)
    ..methods.addAll(_delegateMethods(className, languages)));
}

List<Method> _delegateMethods(String className, List<String> languages) {
  var localeParamName = 'locale';

  return [
    _isSupported(languages, localeParamName),
    _shouldReload(className),
    _load(className, localeParamName),
  ];
}

Method _isSupported(List<String> supportedLanguages, String localParamName) {
  var convertedList = supportedLanguages
      .map<String>((langCode) => '"$langCode"')
      .reduce((value, element) => '$value, $element');

  return Method((builder) => builder
    ..annotations.add(_overrideAnnotation())
    ..returns = refer('bool')
    ..name = 'isSupported'
    ..requiredParameters.add(_localeParameter(localParamName))
    ..lambda = true
    ..body = Code('[$convertedList].contains($localParamName.languageCode)'));
}

Method _shouldReload(String className) {
  return Method((builder) => builder
    ..annotations.add(_overrideAnnotation())
    ..returns = refer('bool')
    ..name = 'shouldReload'
    ..requiredParameters.add(_oldDelegateParameter(className))
    ..lambda = true
    ..body = Code('false'));
}

Method _load(String className, String localeParameterName) {
  return Method(
    (builder) => builder
      ..annotations.add(_overrideAnnotation())
      ..returns = refer('Future<$className>')
      ..name = 'load'
      ..modifier = MethodModifier.async
      ..requiredParameters.add(_localeParameter(localeParameterName))
      ..body = Block.of([
        Code("var translations = $className();"),
        Code("await translations.load($localeParameterName);"),
        Code("return translations;"),
      ]),
  );
}

Parameter _localeParameter(String name) {
  return Parameter((param) => param
    ..name = name
    ..type = refer('Locale'));
}

Parameter _oldDelegateParameter(String className) {
  return Parameter((param) => param
    ..name = 'old'
    ..type = _delegateReference(className));
}

Reference _delegateReference(String className) {
  return refer('LocalizationsDelegate<$className>');
}

Expression _overrideAnnotation() => CodeExpression(Code('override'));
