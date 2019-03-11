part of '../../generator.dart';

class TranslationNode extends Node<Translation, TranslationNode> {
  String name;
  String prefix;
  Translation translation;

  String get _pascalName => name.isEmpty ? name : ReCase(name).pascalCase;

  String get _camelName => name.isEmpty ? name : ReCase(name).camelCase;

  String get _privatePascalPrefixName =>
      (prefix.isNotEmpty ? "_\$$prefix\$" : "_\$") + ReCase(name).pascalCase;

  bool get isInHelper => prefix.isEmpty;

  Reference get _helper => (isInHelper ? _this : innerHelper);

  TranslationNode({
    this.name = "",
    this.prefix = "",
    this.translation,
    isRoot = false,
  }) : super(isRoot: isRoot);

  bool _isLeaf() => translation != null;

  bool _contains(String name) =>
      children.where((child) => child.name == name).toList().isNotEmpty;

  TranslationNode _getChild(String name) =>
      children.firstWhere((child) => child.name == name, orElse: null);

  void _addNode(List<String> parts, {Translation translation}) {
    String nextName = parts.first;
    bool containsNextName = _contains(nextName);

    if (parts.length > 1) {
      if (containsNextName) {
        if (_getChild(nextName)._isLeaf()) {
          throw Exception("Leaf already exsists! - ${nextName}");
        } else {
          List<String> nextParts = List.of(parts);
          nextParts.removeAt(0);

          _getChild(nextName)._addNode(
            nextParts,
            translation: translation,
          );
        }
      } else {
        TranslationNode nextNode =
            TranslationNode(name: nextName, prefix: prefix + _pascalName);
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
            prefix: prefix + _pascalName);
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
