import 'package:rosetta_generator/src/entities/translation.dart';
import 'package:rosetta_generator/src/tree/abstract/tree.dart';
import 'package:rosetta_generator/src/tree/abstract/visitor.dart';
import 'package:rosetta_generator/src/tree/entities/product.dart';
import 'package:rosetta_generator/src/tree/implementation/node.dart';

class TranslationTree extends Tree<TranslationProduct, TranslationNode> {
  TranslationNode rootNode;

  void build(List<Translation> translations, String separator) {
    rootNode = TranslationNode(isRoot: true);
    for (Translation translation in translations) {
      rootNode.add(translation);
    }
  }

  @override
  TranslationProduct visit(
      Visitor<TranslationProduct, TranslationNode> visitor) {
    if (rootNode == null) {
      throw Exception("Tree not generated!");
    }
    return visitor.visit(rootNode);
  }
}
