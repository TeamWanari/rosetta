import 'package:rosetta_generator/src/tree/abstract/node.dart';
import 'package:rosetta_generator/src/tree/abstract/visitor.dart';

abstract class Tree<Result, N extends Node<dynamic, N>> {
  Result visit(Visitor<Result, N> visitor);
}
