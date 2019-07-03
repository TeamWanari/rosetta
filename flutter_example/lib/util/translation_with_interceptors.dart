import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rosetta/rosetta.dart';

part 'translation_with_interceptors.g.dart';

@Stone(path: 'i18n')
class TranslationWithInterceptors with _$TranslationWithInterceptorsHelper {
  static LocalizationsDelegate<TranslationWithInterceptors> delegate = _$TranslationWithInterceptorsDelegate();

  static TranslationWithInterceptors of(BuildContext context) {
    return Localizations.of(context, TranslationWithInterceptors);
  }

  @Intercept.withFilter(filter: ".*filtered.*")
  String filteredIntercept(String b) => ">>filtered>> $b";
  
  @Intercept.simple()
  String simpleIntercept(String translation) => ">>> $translation";
  
}