import 'package:rosetta_generator/src/tree/abstract/node.dart';

abstract class Visitor<Result, N extends Node<dynamic, N>> {
  Result visit(N node);
}
