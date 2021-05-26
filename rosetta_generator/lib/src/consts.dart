import 'package:code_builder/code_builder.dart';
import 'package:rosetta_generator/src/utils.dart';

const String strLocaleName = "locale";
const String strLoadMethodName = "load";
const String strTranslateMethodName = "_translate";
const String strTranslationsFieldName = "_translations";
const String strResolutionsName = "_resolutions";
const String strResolveMethodName = "resolve";
const String strLoadJsonStr = "jsonStr";
const String strLoadJsonMap = "jsonMap";
const String strKeyName = "key";
const String strInnerHelper = "_\$";
const String strPlurals = "_plurals";

const Reference refLocale = Reference(strLocaleName);
const Reference refOverrideAnnotation = Reference("override");

const Reference refResolve = Reference(strResolveMethodName);
const Reference refTranslate = Reference(strTranslateMethodName);
const Reference refTranslations = Reference(strTranslationsFieldName);
const Reference refResolutions = Reference(strResolutionsName);
const Reference refJsonStr = Reference(strLoadJsonStr);
const Reference refJsonMap = Reference(strLoadJsonMap);
const Reference refKey = Reference(strKeyName);
const Reference refInnerHelper = Reference(strInnerHelper);
const Reference refThis = Reference("this");
const Reference refPlurals = Reference(strPlurals);

final Parameter localeParameter = Parameter((pb) => pb
  ..name = strLocaleName
  ..type = typeOf('Locale'));
