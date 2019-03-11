part of '../../generator.dart';

class TranslationTree extends Tree<TranslationProduct, TranslationNode> {
  TranslationNode rootNode;

  void build(List<Translation> translations) {
    rootNode = TranslationNode(isRoot: true);
    for (Translation translation in translations) {
      rootNode.add(translation);
    }
  }

  @override
  TranslationProduct visit(Visitor<TranslationProduct, TranslationNode> visitor) {
    if (rootNode == null) {
      throw Exception("Tree not generated!");
    }
    return visitor.visit(rootNode);
  }
}
