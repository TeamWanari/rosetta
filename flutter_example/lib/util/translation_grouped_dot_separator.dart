import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rosetta/rosetta.dart';

import 'package:sprintf/sprintf.dart';

part 'translation_grouped_dot_separator.g.dart';

@Stone(path: 'i18n', grouping: Grouping.withSeparator())
class TranslationGroupedDotSeparator with _$TranslationGroupedDotSeparatorHelper {
  static LocalizationsDelegate<TranslationGroupedDotSeparator> delegate = _$TranslationGroupedDotSeparatorDelegate();

  static TranslationGroupedDotSeparator of(BuildContext context) {
    return Localizations.of(context, TranslationGroupedDotSeparator);
  }

  @Intercept.withFilter(filter: ".*filtered.*")
  String paramIntercept(String b, var args) => sprintf(b, args);

  @Intercept.simple()
  String simpleIntercept(String translation) => translation;
}
