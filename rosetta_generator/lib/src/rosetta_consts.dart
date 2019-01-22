part of 'rosetta_generator.dart';

const String _keysClassName = "_\$Keys";
const String _localeName = "locale";
const String _loadMethodName = "load";
const String _translateMethodName = "_translate";
const String _translationsFieldName = "_translations";
const String _loadJsonStr = "jsonStr";
const String _loadJsonMap = "jsonMap";
const String _keyName = "key";

const Reference locale = Reference(_localeName);
const Reference overrideAnnotation = Reference("override");

const Reference translate = Reference(_translateMethodName);
const Reference translations = Reference(_translationsFieldName);
const Reference jsonStr = Reference(_loadJsonStr);
const Reference jsonMap = Reference(_loadJsonMap);
const Reference key = Reference(_keyName);

final Parameter localeParameter = Parameter((pb) => pb
  ..name = _localeName
  ..type = _typeOf('Locale'));
