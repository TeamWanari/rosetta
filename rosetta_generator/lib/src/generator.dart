import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:rosetta/rosetta.dart';
import 'package:rosetta_generator/src/delegate.dart';
import 'package:rosetta_generator/src/entities/translation.dart';
import 'package:rosetta_generator/src/helper.dart';
import 'package:rosetta_generator/src/keys.dart';
import 'package:rosetta_generator/src/utils.dart';
import 'package:rosetta_generator/src/validations.dart';
import 'package:source_gen/source_gen.dart';

class RosettaStoneGenerator extends GeneratorForAnnotation<Stone> {
  const RosettaStoneGenerator();

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    checkElementIsClass(element);

    Stone stone = parseStone(annotation);

    var className = element.name!;
    var keysClassName = className + "Keys";
    var interceptionsClassName = "_\$${className}Interceptions";
    var languages = await getLanguages(buildStep, stone);

    List<Translation> translations;

    try {
      translations = await getKeyMap(buildStep, stone);
    } on FormatException catch (_) {
      throw InvalidGenerationSourceError(
        "Invalid JSON format! Validate the JSON's contents.",
      );
    }

    checkTranslationKeyMap(translations);

    var interceptors = getInterceptors(element as ClassElement);

    final file = Library((lb) => lb
      ..body.addAll([
            generateDelegate(className, languages),
            generateKeysClass(keysClassName, translations),
          ] +
          generateHelper(className, keysClassName, interceptionsClassName,
              stone, translations, interceptors)));

    final DartEmitter emitter = DartEmitter(Allocator());
    return DartFormatter().format('${file.accept(emitter)}');
  }
}
