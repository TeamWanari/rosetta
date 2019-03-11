part of '../../generator.dart';

abstract class Visitor<Result, N extends Node<dynamic, N>> {
  Result visit(N node);
}
