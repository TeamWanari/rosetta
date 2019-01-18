import 'package:rosetta/rosetta.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

part 'translation.g.dart';

@Stone(path: 'i18n')
class Translation with _$TranslationHelper { 
  static LocalizationsDelegate<Translation> delegate = _$TranslationDelegate();

  static Translation of(BuildContext context) {
    return Localizations.of(context, Translation);
  }
}