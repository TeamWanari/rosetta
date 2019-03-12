abstract class Node<Content, N extends Node<Content, N>> {
  final List<N> children = [];
  final bool isRoot;

  Node({this.isRoot = false});

  void add(Content content);
}
