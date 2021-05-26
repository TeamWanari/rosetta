import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:rosetta/rosetta.dart';
import 'package:rosetta_generator/src/entities/translation.dart';
import 'package:source_gen/source_gen.dart';

final TypeChecker interceptorTypeChecker = TypeChecker.fromRuntime(Intercept);

void checkElementIsClass(Element element) {
  if (element is! ClassElement) {
    throw InvalidGenerationSourceError(
        "Stoned element is not a Class! Stone should be used on Classes.",
        element: element);
  }
}

void checkTranslationKeyMap(List<Translation> translations) {
  if (translations.isEmpty) {
    return;
  }

  translations.sort((translation1, translation2) =>
      translation1.translations.length - translation2.translations.length);

  int requiredLength = translations.first.translations.length;

  List<String> invalidKeys = keysOf(translations
      .where((translation) => translation.translations.length < requiredLength)
      .toList());

  if (invalidKeys.isNotEmpty) {
    throw InvalidGenerationSourceError(
      "Invalid key pool: Key(s) are missing from a JSON!" +
          " Check the JSON's contents and add the required keys." +
          " Possibly missing: ${invalidKeys.join(", ")} .",
    );
  }
}

void checkPluralMaps(Map<String, dynamic> pluralTranslations, AssetId entity) {
  /// Throw an exception if there's no [other] field in the plural JSON objects
  pluralTranslations.forEach((key, pluralSubMap) {
    if (!(pluralSubMap.containsKey("other"))) {
      throw InvalidGenerationSourceError(
          "Plural translation object with key [$key] does not contain required [other] field! Translation file: [${entity
              .uri.path}]"
      );
    }
  });
}

void checkInterceptorFormat(MethodElement element) {
  var annotation = interceptorTypeChecker.firstAnnotationOfExact(element);
  var isFiltered = annotation.getField("isFiltered").toBoolValue();

  if (element.returnType.getDisplayString(withNullability: false) != "String") {
    throw InvalidGenerationSourceError(
        "The intercepted method's return type should be String!" +
            " Please change the return type.",
        element: element);
  }

  if (isFiltered) {
    if (element.parameters.isEmpty) {
      throw InvalidGenerationSourceError(
          "The filtered intercepted method's! first parameter" +
              " should be String! Please add a String paramter.",
          element: element);
    } else if (element.parameters.first.type
            .getDisplayString(withNullability: false) !=
        "String") {
      throw InvalidGenerationSourceError(
          "The filtered intercepted method's! first parameter" +
              " should be String! Please provide a String" +
              " type first parameter.",
          element: element);
    }

    var regexpString = annotation.getField("filter").toStringValue();

    if (regexpString == null) {
      throw InvalidGenerationSourceError(
          "The given filter should not be null!" +
              " Please provide a valid RegExp or" +
              " use [Intercept.simple()] annotation.",
          element: element);
    }

    try {
      RegExp(regexpString);
    } on FormatException catch (_) {
      throw InvalidGenerationSourceError(
          "The given filter is not a RegExp!" +
              " Check the RegExp's syntax. Current string: $regexpString .",
          element: element);
    }
  }
}
