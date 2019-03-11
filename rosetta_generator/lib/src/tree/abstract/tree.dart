part of '../../generator.dart';

abstract class Tree<Result, N extends Node<dynamic, N>> {
  Result visit(Visitor<Result, N> visitor);
}
