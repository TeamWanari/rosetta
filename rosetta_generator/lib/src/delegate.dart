import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';
import 'package:rosetta_generator/src/consts.dart';
import 'package:rosetta_generator/src/utils.dart';

Class generateDelegate(String className, List<String> languages) {
  var delegateClassName = "${className}Delegate";

  return Class((builder) => builder
    ..docs.addAll([
      "/// A factory for a set of localized resources of type ${className}, to be loaded by a",
      "/// [Localizations] widget.",
    ])
    ..name = '_\$$delegateClassName'
    ..extend = localizationDelegateOf(className)
    ..methods.addAll(_delegateMethods(className, languages)));
}

List<Method> _delegateMethods(String className, List<String> languages) => [
      _isSupported(languages),
      _shouldReload(className),
      _load(className),
    ];

Method _isSupported(List<String> supportedLanguages) => Method(
      (builder) => builder
        ..docs.addAll([
          "/// Whether the the given [locale.languageCode] code has a JSON associated with it.",
        ])
        ..annotations.add(refOverrideAnnotation)
        ..returns = boolType
        ..name = 'isSupported'
        ..requiredParameters.add(localeParameter)
        ..lambda = true
        ..body = literalConstList(supportedLanguages)
            .property("contains")
            .call([refLocale.property("languageCode")]).code,
    );

Method _shouldReload(String className) {
  return Method((mb) => mb
    ..docs.addAll([
      "/// Returns true if the resources for this delegate should be loaded",
      "/// again by calling the [load] method.",
    ])
    ..annotations.add(refOverrideAnnotation)
    ..returns = boolType
    ..name = 'shouldReload'
    ..requiredParameters.add(Parameter(
      (param) => param
        ..name = 'old'
        ..type = localizationDelegateOf(className),
    ))
    ..lambda = true
    ..body = literalFalse.code);
}

Method _load(String className) {
  var fieldName = ReCase(className).camelCase;
  var field = refer(fieldName);

  return Method(
    (mb) => mb
      ..docs.addAll([
        "/// Loads the JSON associated with the given [locale] using [Strings].",
      ])
      ..annotations.add(refOverrideAnnotation)
      ..returns = futureOf(className)
      ..name = 'load'
      ..modifier = MethodModifier.async
      ..requiredParameters.add(localeParameter)
      ..body = Block.of([
        refer(className).newInstance([]).assignVar(fieldName).statement,
        field.property(strLoadMethodName).call([refLocale]).awaited.statement,
        field.returned.statement,
      ]),
  );
}
