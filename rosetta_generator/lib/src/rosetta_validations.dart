part of 'rosetta_generator.dart';

void checkElementIsClass(Element element) {
  if (element is! ClassElement) {
    throw InvalidGenerationSourceError(
        "Stoned element is not a Class! Stone should be used on Classes.",
        element: element);
  }
}

void checkDirectoryExists(String path) async {
  bool exists = await Directory(path).exists();

  if (!exists) {
    throw InvalidGenerationSourceError(
      "Given path doesn't exist! Provide a valid path.",
    );
  }
}

void checkTranslationKeyMap(Map<String, List<String>> keyMap) {
  var ascendingKeyLengths = keyMap
      .map((string, list) => MapEntry(string, list.length))
      .entries
      .toList();
  ascendingKeyLengths.sort((entry1, entry2) => entry2.value - entry1.value);

  int requiredLength = ascendingKeyLengths.first.value;

  var invalidKeys = ascendingKeyLengths
      .where((entry) => entry.value < requiredLength)
      .map((entry) => entry.key);

  if (invalidKeys.length > 0) {
    throw InvalidGenerationSourceError(
      "Invalid key pool: Key(s) are missing from a JSON!" +
          " Check the JSON's contents and add the required keys." +
          " Possibly missing: ${invalidKeys.join(", ")} .",
    );
  }
}

void checkInterceptorFormat(List<MethodElement> interceptors) {
  for (MethodElement interceptor in interceptors) {
    var annotation =
        _interceptorTypeChecker.firstAnnotationOfExact(interceptor);
    var isFiltered = annotation.getField("isFiltered").toBoolValue();

    if (interceptor.returnType.name != "String") {
      throw InvalidGenerationSourceError(
          "The intercepted method's return type should be String!" +
              " Please change the return type.",
          element: interceptor);
    }

    if (isFiltered) {
      if (interceptor.parameters.isEmpty) {
        throw InvalidGenerationSourceError(
            "The filtered intercepted method's! first parameter" +
                " should be String! Please add a String paramter.",
            element: interceptor);
      } else if (interceptor.parameters.first.type.name != "String") {
        throw InvalidGenerationSourceError(
            "The filtered intercepted method's! first parameter" +
                " should be String! Please provide a String" +
                " type first parameter.",
            element: interceptor);
      }

      var regexpString = annotation.getField("filter").toStringValue();

      if (regexpString == null) {
        throw InvalidGenerationSourceError(
            "The given filter should not be null!" +
                " Please provide a valid RegExp or" +
                " use [Intercept.simple()] annotation.",
            element: interceptor);
      }

      try {
        RegExp(regexpString);
      } on FormatException catch (_) {
        throw InvalidGenerationSourceError(
            "The given filter is not a RegExp!" +
                " Check the RegExp's syntax. Current string: $regexpString .",
            element: interceptor);
      }
    }
  }
}
