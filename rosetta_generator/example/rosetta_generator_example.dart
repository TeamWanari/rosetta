import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rosetta/rosetta.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

part 'rosetta_generator_example.g.dart';

@Stone(path: 'i18n')
class Translation with _$TranslationHelper { 
  static LocalizationsDelegate<Translation> delegate = _$TranslationDelegate();

  static Translation of(BuildContext context) {
    return Localizations.of(context, Translation);
  }
}