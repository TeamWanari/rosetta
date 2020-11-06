import 'package:code_builder/code_builder.dart';
import 'package:rosetta_generator/src/utils.dart';

const String strKeysClassName = "_\$Keys";
const String strLocaleName = "locale";
const String strLoadMethodName = "load";
const String strTranslateMethodName = "_translate";
const String strTranslationsFieldName = "_translations";
const String strLoadJsonStr = "jsonStr";
const String strLoadJsonMap = "jsonMap";
const String strKeyName = "key";
const String strInnerHelper = "_\$";
const String strAssetName = "assetName";
const String strReplaceKey = "{0}";

const Reference refLocale = Reference(strLocaleName);
const Reference refOverrideAnnotation = Reference("override");

const Reference refAssetName = Reference(strAssetName);
const Reference refTranslate = Reference(strTranslateMethodName);
const Reference refTranslations = Reference(strTranslationsFieldName);
const Reference refJsonStr = Reference(strLoadJsonStr);
const Reference refJsonMap = Reference(strLoadJsonMap);
const Reference refKey = Reference(strKeyName);
const Reference refKeysClass = Reference(strKeysClassName);
const Reference refInnerHelper = Reference(strInnerHelper);
const Reference refThis = Reference("this");

final Parameter localeParameter = Parameter((pb) => pb
  ..name = strLocaleName
  ..type = typeOf('Locale'));
