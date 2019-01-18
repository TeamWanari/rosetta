import 'dart:async';
import 'dart:convert';

import 'package:rosetta/rosetta.dart';

/*
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
*/

part 'rosetta_generator_example.g.dart';

@Stone(path: 'i18n')
class Translation with _$TranslationHelper {
  static LocalizationsDelegate<Translation> delegate = _$TranslationDelegate();

  static Translation of(BuildContext context) {
    return Localizations.of(context, Translation);
  }
}
