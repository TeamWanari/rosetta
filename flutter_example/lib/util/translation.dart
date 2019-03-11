import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rosetta/rosetta.dart';

part 'translation.g.dart';

@Stone(path: 'i18n')
class Translation with _$TranslationHelper {
  static LocalizationsDelegate<Translation> delegate = _$TranslationDelegate();

  static Translation of(BuildContext context) {
    return Localizations.of(context, Translation);
  }

  @Intercept.withFilter(filter: ".*ello.*")
  String interceptEllo(String b) => b;

  @Intercept.simple()
  String interceptAll(String a) => a;
}
