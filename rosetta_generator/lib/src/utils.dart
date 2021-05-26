import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:glob/glob.dart';
import 'package:rosetta/rosetta.dart';
import 'package:rosetta_generator/src/entities/interceptor.dart';
import 'package:rosetta_generator/src/entities/translation.dart';
import 'package:rosetta_generator/src/validations.dart';
import 'package:source_gen/source_gen.dart';

Stone parseStone(ConstantReader annotation) => Stone(
      path: annotation.peek("path")?.stringValue,
      package: annotation.peek("package")?.stringValue,
      grouping: annotation.peek("grouping") != null
          ? Grouping.withSeparator(
              separator:
                  annotation.peek("grouping").peek("separator").stringValue,
            )
          : null,
    );

//TODO: getLanguage+getKayMap merge => Localization Class (language keys, key)

/// Find all referenced translation files for [Stone.path]
Future<List<String>> getLanguages(BuildStep step, Stone stone) async =>
    await step
        .findAssets(Glob(stone.path, recursive: true))
        .map((it) => _assetIdToLocaleId(it, stone))
        .toList();

/// All translations grouped by their keys
Future<List<Translation>> getKeyMap(BuildStep step, Stone stone) async {
  var mapping = <String, List<String>>{};

  /// Find all referenced translation files for [Stone.path]
  var assets =
      await step.findAssets(Glob(stone.path, recursive: true)).toList();

  /// Parse all translations
  for (var entity in assets) {
    Map<String, dynamic> jsonMap = json.decode(await step.readAsString(entity));
    jsonMap.removeWhere((key, value) => value is! String);
    Map<String, String> translationMap = jsonMap
        .map<String, String>((key, value) => MapEntry(key, value as String));

    /// Group translations by key
    translationMap.forEach(
      (key, value) => (mapping[key] ??= <String>[]).add(value),
    );
  }

  /// Convert the map to translation objects
  var translations = <Translation>[];
  mapping.forEach(
    (id, trans) => translations.add(
      Translation(
          key: id, translations: trans, separator: stone.grouping?.separator),
    ),
  );

  return translations;
}

Future<List<String>> getPluralKeys(BuildStep step, Stone stone) async {
  var keys = <String>[];

  /// Find all referenced translation files for [Stone.path]
  var assets =
      await step.findAssets(Glob(stone.path, recursive: true)).toList();

  /// Parse all plurals
  for (var entity in assets) {
    Map<String, dynamic> jsonMap = json.decode(await step.readAsString(entity));

    /// Ignore non-plural translations
    jsonMap.removeWhere((key, value) => value is! Map);

    /// Validate the plural maps
    checkPluralMaps(jsonMap, entity);

    keys.addAll(jsonMap.keys);
  }

  return keys.toSet().toList();
}

Map<MethodElement, List<String>> sortKeysByInterceptors(
  List<Translation> translations,
  List<Interceptor> interceptors,
) {
  List<Translation> remainingTranslations = List.of(translations);

  return Map.fromIterable(
    interceptors,
    key: (interceptor) => interceptor.element,
    value: (interceptor) {
      var matchingKeys = <String>[];
      var filter = interceptor.filter;

      if (filter != null) {
        /// [Intercept] annotation with filter
        remainingTranslations.forEach((trans) {
          if (trans.translations.where(filter.hasMatch).toList().isNotEmpty) {
            matchingKeys.add(trans.key);
          }
        });

        matchingKeys.forEach(remainingTranslations.remove);
      } else {
        /// [Intercept] annotation without filter
        matchingKeys.addAll(keysOf(remainingTranslations));
        remainingTranslations.clear();
      }

      return matchingKeys;
    },
  )

    /// Add the remaining keys as
    ..[null] = keysOf(remainingTranslations);
}

List<Interceptor> getInterceptors(ClassElement classElement) =>
    classElement.methods
        .where((m) => interceptorTypeChecker.hasAnnotationOfExact(m))
        .map((element) => Interceptor(element: element))
        .toList();

String _assetIdToLocaleId(AssetId assetId, Stone stone) {
  return assetId.uri.pathSegments.last.split('.').first;
}

String stoneAssetsPath(Stone stone) => stone.package != null
    ? "packages/${stone.package}/${stone.path}"
    : stone.path;

Reference localizationDelegateOf(String className) => TypeReference(
      (trb) => trb
        ..symbol = "LocalizationsDelegate"
        ..types.add(typeOf(className)),
    );

Reference futureOf(String className) => TypeReference(
      (trb) => trb
        ..symbol = "Future"
        ..types.add(typeOf(className)),
    );

Reference typeOf(String className) => TypeReference(
      (trb) => trb..symbol = className,
    );

Reference mapOf(Reference keyType, Reference valueType) => TypeReference(
      (trb) => trb
        ..symbol = "Map"
        ..types.addAll([keyType, valueType]),
    );

Reference get boolType => TypeReference(
      (trb) => trb..symbol = "bool",
    );

Reference get dynamicType => TypeReference(
      (trb) => trb..symbol = "dynamic",
    );

Reference get stringType => TypeReference(
      (trb) => trb..symbol = "String",
    );

Reference get localeType => TypeReference(
      (trb) => trb..symbol = "Locale",
    );

Reference get numberType => TypeReference(
      (trb) => trb..symbol = "num",
    );
