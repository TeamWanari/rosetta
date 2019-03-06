part of '../generator.dart';

class Tree {
  Node rootNode = Node(isRoot: true, name: "Root");

  List<Method> generateMethods(
      List<Translation> translations,
      List<Interceptor> interceptors,
      List<Class> classList,
      Reference helperRef,
      {bool printTree = false}) {
    for (Translation translation in translations) {
      rootNode.addTranslation(translation);
    }

    return rootNode.generateClasses(classList, interceptors, helperRef);
  }
}
