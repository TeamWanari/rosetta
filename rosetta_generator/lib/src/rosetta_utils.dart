part of 'rosetta_generator.dart';

Stone parseStone(ConstantReader annotation) => Stone(
      path: annotation.peek("path")?.stringValue,
      package: annotation.peek("package")?.stringValue,
    );

/// Find all referenced translation files for [Stone.path]
Future<List<String>> getLanguages(BuildStep step, String path) async =>
    await step
        .findAssets(Glob(path, recursive: true))
        .map(_assetIdToLocaleId)
        .toList();

/// All translations grouped by their keys
Future<Map<String, List<String>>> getKeyMap(BuildStep step, String path) async {
  var mapping = <String, List<String>>{};

  /// Find all referenced translation files for [Stone.path]
  var assets = await step.findAssets(Glob(path, recursive: true)).toList();

  /// Parse all translations
  for (var entity in assets) {
    Map<String, dynamic> jsonMap = json.decode(await step.readAsString(entity));
    Map<String, String> translationMap = jsonMap
        .map<String, String>((key, value) => MapEntry(key, value as String));

    /// Group translations by key
    translationMap.forEach(
      (key, value) => (mapping[key] ??= <String>[]).add(value),
    );
  }

  return mapping;
}

Map<MethodElement, List<String>> sortKeysByInterceptors(
  Map<String, List<String>> keyMap,
  List<MethodElement> interceptors,
) {
  Map<String, List<String>> remainingKeyMap = Map.of(keyMap);

  return Map.fromIterable(
    interceptors,
    key: (interceptor) => interceptor,
    value: (interceptor) {
      var annotation =
          _interceptorTypeChecker.firstAnnotationOfExact(interceptor);
      var matchingKeys = <String>[];
      var filter = annotation.getField("filter").toStringValue();

      if (filter != null) {
        /// [Intercept] annotation with filter
        var filterRegex = RegExp(filter);

        remainingKeyMap.forEach((key, values) {
          if (values.where(filterRegex.hasMatch).toList().isNotEmpty) {
            matchingKeys.add(key);
          }
        });

        matchingKeys.forEach(remainingKeyMap.remove);
      } else {
        /// [Intercept] annotation without filter
        matchingKeys.addAll(remainingKeyMap.keys);
        remainingKeyMap.clear();
      }

      return matchingKeys;
    },
  )

    /// Add the remaining keys as
    ..[null] = remainingKeyMap.keys.toList();
}

List<MethodElement> getInterceptors(ClassElement classElement) =>
    classElement.methods
        .where((m) => _interceptorTypeChecker.hasAnnotationOfExact(m))
        .toList();

String _assetIdToLocaleId(AssetId assetId) =>
    assetId.uri.pathSegments.last.split(".").first;

String _stoneAssetsPath(Stone stone) => stone.package != null
    ? "packages/${stone.package}/${stone.path}"
    : stone.path;

Reference _localizationDelegateOf(String className) => TypeReference(
      (trb) => trb
        ..symbol = "LocalizationsDelegate"
        ..types.add(_typeOf(className)),
    );

Reference _futureOf(String className) => TypeReference(
      (trb) => trb
        ..symbol = "Future"
        ..types.add(_typeOf(className)),
    );

Reference _typeOf(String className) => TypeReference(
      (trb) => trb..symbol = className,
    );

Reference _mapOf(Reference keyType, Reference valueType) => TypeReference(
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
