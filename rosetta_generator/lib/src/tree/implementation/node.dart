import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';
import 'package:rosetta_generator/src/consts.dart';
import 'package:rosetta_generator/src/entities/translation.dart';
import 'package:rosetta_generator/src/tree/abstract/node.dart';

class TranslationNode extends Node<Translation, TranslationNode> {
  String name;
  String prefix;
  Translation translation;

  String get pascalName => name.isEmpty ? name : ReCase(name).pascalCase;

  String get camelName => name.isEmpty ? name : ReCase(name).camelCase;

  String get privatePascalPrefixName =>
      (prefix.isNotEmpty ? "_\$$prefix\$" : "_\$") + ReCase(name).pascalCase;

  bool get isInHelper => prefix.isEmpty;

  Reference get helper => (isInHelper ? refThis : refInnerHelper);

  TranslationNode({
    this.name = "",
    this.prefix = "",
    this.translation,
    isRoot = false,
  }) : super(isRoot: isRoot);

  bool isLeaf() => translation != null;

  bool contains(String name) =>
      children.where((child) => child.name == name).toList().isNotEmpty;

  TranslationNode getChild(String name) =>
      children.firstWhere((child) => child.name == name, orElse: null);

  void _addNode(List<String> parts, {Translation translation}) {
    String nextName = parts.first;
    bool containsNextName = contains(nextName);

    if (parts.length > 1) {
      if (containsNextName) {
        if (getChild(nextName).isLeaf()) {
          throw Exception("Leaf already exsists! - ${nextName}");
        } else {
          List<String> nextParts = List.of(parts);
          nextParts.removeAt(0);

          getChild(nextName)._addNode(
            nextParts,
            translation: translation,
          );
        }
      } else {
        TranslationNode nextNode =
            TranslationNode(name: nextName, prefix: prefix + pascalName);
        children.add(nextNode);

        List<String> nextParts = List.of(parts);
        nextParts.removeAt(0);
        nextNode._addNode(
          nextParts,
          translation: translation,
        );
      }
    } else {
      if (!containsNextName) {
        TranslationNode nextNode = TranslationNode(
            translation: translation,
            name: nextName,
            prefix: prefix + pascalName);
        children.add(nextNode);
      } else {
        throw Exception("Leaf already exsists! - $nextName}");
      }
    }
  }

  @override
  void add(Translation content) {
    if (!isRoot) {
      throw Exception("Translatins should only be added to the root node!");
    }

    var listClone = List.of(content.tieredKey);
    _addNode(listClone, translation: content);
  }
}
