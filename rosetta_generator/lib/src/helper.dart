import 'package:code_builder/code_builder.dart';
import 'package:rosetta/rosetta.dart';
import 'package:rosetta_generator/src/consts.dart';
import 'package:rosetta_generator/src/entities/interceptor.dart';
import 'package:rosetta_generator/src/entities/translation.dart';
import 'package:rosetta_generator/src/tree/abstract/visitor.dart';
import 'package:rosetta_generator/src/tree/entities/product.dart';
import 'package:rosetta_generator/src/tree/implementation/tree.dart';
import 'package:rosetta_generator/src/tree/implementation/visitor.dart';
import 'package:rosetta_generator/src/utils.dart';

List<Class> generateHelper(
  String className,
  Stone stone,
  List<Translation> translations,
  List<Interceptor> interceptors,
) {
  TranslationTree tree = TranslationTree();
  tree.build(translations, stone.grouping?.separator);

  Visitor visitor = TranslationVisitor(
      interceptors: interceptors, helperRef: refer("_\$${className}Helper"));

  ///The result should be added to the Helper class and the file.
  TranslationProduct product = tree.visit(visitor);

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
          ..name = strTranslationsFieldName
          ..type = mapOf(stringType, stringType)),
      )
      ..methods.add(generateLoader(stone))
      ..methods.add(generateTranslationMethod())
      ..update((cb) {
        if (interceptors.isNotEmpty) {
          cb.methods.addAll(generateInterceptorMethods(interceptors));
        }

        ///The result's methods should be added to the Helper and
        ///also a private field for each.
        cb.methods.addAll(product.helperMethods);
        cb.fields.addAll(product.helperMethods
            .where((child) => child.returns != stringType)
            .map((child) => Field((fieldBuilder) => fieldBuilder
              ..name = "_${child.name}"
              ..type = child.returns))
            .toList());
      }),
  );

  ///The additional Classes in the result must be included in the file.
  return [helper] + product.translationClasses;
}

Method generateLoader(Stone stone) {
  var assetLoader = refer("rootBundle").property("loadString");
  var decodeJson = refer("json").property("decode");
  var assetLoaderTemplate =
      "${stoneAssetsPath(stone)}/\${$strLocaleName.languageCode}.json";

  return Method(
    (mb) => mb
      ..docs.addAll([
        "/// Loads and decodes the JSON associated with the given [locale].",
      ])
      ..name = strLoadMethodName
      ..returns = futureOf("void")
      ..modifier = MethodModifier.async
      ..requiredParameters.add(localeParameter)
      ..body = Block.of([
        assetLoader
            .call([literalString(assetLoaderTemplate)])
            .awaited
            .assignVar(strLoadJsonStr)
            .statement,
        decodeJson
            .call([refJsonStr])
            .assignVar(strLoadJsonMap, mapOf(stringType, dynamicType))
            .statement,
        refTranslations
            .assign(
              refJsonMap.property("map<String, String>").call([
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
        ..name = strTranslateMethodName
        ..lambda = true
        ..requiredParameters.add(
          Parameter((pb) => pb
            ..name = strKeyName
            ..named = true
            ..type = stringType),
        )
        ..body = refTranslations.index(refKey).code
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
