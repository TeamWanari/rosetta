import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:recase/recase.dart';
import 'package:rosetta/rosetta.dart';
import 'package:source_gen/source_gen.dart';

part 'consts.dart';

part 'delegate.dart';

part 'entities/interceptor.dart';

part 'entities/translation.dart';

part 'helper.dart';

part 'keys.dart';

part 'tree/abstract/node.dart';

part 'tree/abstract/tree.dart';

part 'tree/abstract/visitor.dart';

part 'tree/implementation/node.dart';

part 'tree/implementation/product.dart';

part 'tree/implementation/tree.dart';

part 'tree/implementation/visitor.dart';

part 'utils.dart';

part 'validations.dart';

class RosettaStoneGenerator extends GeneratorForAnnotation<Stone> {
  const RosettaStoneGenerator();

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    checkElementIsClass(element);

    Stone stone = parseStone(annotation);

    var className = element.name;
    var languages = await getLanguages(buildStep, stone.path);

    List<Translation> translations;

    try {
      translations = await getKeyMap(buildStep, stone.path);
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
            generateKeysClass(translations),
          ] +
          generateHelper(className, stone, translations, interceptors)));

    final DartEmitter emitter = DartEmitter(Allocator());
    return DartFormatter().format('${file.accept(emitter)}');
  }
}
