import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rosetta/rosetta.dart';

import 'package:sprintf/sprintf.dart';

part 'translation_grouped_underline_separator.g.dart';

@Stone(path: 'i18n', grouping: Grouping.withSeparator(separator: '_'))
class TranslationGroupedUnderlineSeparator
    with _$TranslationGroupedUnderlineSeparatorHelper {
  static LocalizationsDelegate<TranslationGroupedUnderlineSeparator> delegate =
      _$TranslationGroupedUnderlineSeparatorDelegate();

  static TranslationGroupedUnderlineSeparator of(BuildContext context) {
    return Localizations.of(context, TranslationGroupedUnderlineSeparator);
  }

  @Intercept.withFilter(filter: ".*filtered.*")
  String paramIntercept(String b, var args) => sprintf(b, args);

  @Intercept.simple()
  String simpleIntercept(String translation) => translation;
}
