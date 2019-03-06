part of '../generator.dart';

class Node {
  String name;
  String prefix;
  Translation translation;
  List<Node> children;
  bool isRoot;

  String get _pascalName => ReCase(name).pascalCase;

  String get _camelName => ReCase(name).camelCase;

  String get _privatePascalPrefixName =>
      (prefix.isNotEmpty ? "_\$$prefix\$" : "_\$") + ReCase(name).pascalCase;

  bool get isInHelper => prefix.isEmpty;

  Reference get _helper => (isInHelper ? _this : innerHelper);

  Node(
      {this.isRoot = false,
      this.name = "",
      this.prefix = "",
      this.translation,
      this.children}) {
    children = List<Node>();
  }

  bool _isLeaf() => translation != null;

  bool _contains(String name) =>
      children.where((child) => child.name == name).toList().isNotEmpty;

  Node _getChild(String name) =>
      children.firstWhere((child) => child.name == name, orElse: null);

  void _addNode(List<String> parts,
      {String data, Translation translation, String parentPrefix = ""}) {
    String nextName = parts.first;
    bool containsNextName = _contains(nextName);

    if (parts.length > 1) {
      if (containsNextName) {
        if (_getChild(nextName)._isLeaf()) {
          throw Exception("Leaf already exsists! - ${nextName}");
        } else {
          List<String> nextParts = List.of(parts);
          nextParts.removeAt(0);

          _getChild(nextName)._addNode(nextParts,
              parentPrefix: parentPrefix + nextName,
              data: data,
              translation: translation);
        }
      } else {
        Node nextNode = Node(name: nextName, prefix: parentPrefix);
        children.add(nextNode);

        List<String> nextParts = List.of(parts);
        nextParts.removeAt(0);
        nextNode._addNode(nextParts,
            parentPrefix: parentPrefix + nextName,
            data: data,
            translation: translation);
      }
    } else {
      if (!containsNextName) {
        Node nextNode = Node(
            translation: translation, name: nextName, prefix: parentPrefix);
        children.add(nextNode);
      } else {
        throw Exception("Leaf already exsists! - $nextName}");
      }
    }
  }

  void addTranslation(Translation translation) {
    if (!isRoot) {
      throw Exception("Translatins should only be added to the root node!");
    }
    _addNode(List.of(translation.tieredKey),
        parentPrefix: "", translation: translation);
  }

  List<Method> generateClasses(List<Class> classList,
      List<Interceptor> interceptors, Reference helperRef,
      {String pascalPrefix = ""}) {
    if (_isLeaf()) {
      return [_generateLeafMethod(interceptors)];
    } else {
      List<Method> childMethods = _getChildMethods(
          children, classList, interceptors, helperRef,
          pascalPrefix: pascalPrefix);

      if (!isRoot) {
        classList.add(_generateNodeClass(childMethods, helperRef));
        return [_generateNodeMethod()];
      } else {
        return childMethods;
      }
    }
  }

  Method _generateNodeMethod() {
    return Method(
      (mb) => mb
        ..name = _camelName
        ..type = MethodType.getter
        ..lambda = true
        ..body = refer("_$_camelName")
            .assignNullAware(refer(_privatePascalPrefixName)
                .newInstance([isInHelper ? _this : innerHelper]))
            .code
        ..returns = refer(_privatePascalPrefixName),
    );
  }

  Method _generateLeafMethod(List<Interceptor> interceptors) {
    Iterable<Interceptor> matchResults = interceptors.where((i) =>
        i.filter == null ||
        translation.translations.where(i.filter.hasMatch).toList().isNotEmpty);

    Interceptor interceptor =
        matchResults.isNotEmpty ? matchResults.first : null;

    return Method((mb) => mb
      ..name = _camelName
      ..lambda = true
      ..returns = stringType
      ..update((methodBuilder) {
        switch (interceptor?.parameterList?.length ?? 0) {
          case 0:
            _buildGetterMethod(methodBuilder);
            break;
          case 1:
            _buildSimpleInterceptorMethod(methodBuilder, interceptor);
            break;
          default:
            _buildParametrizedInterceptorMethod(methodBuilder, interceptor);
        }
      }));
  }

  void _buildGetterMethod(MethodBuilder methodBuilder) {
    methodBuilder
      ..type = MethodType.getter
      ..body = _helper
          .property(_translateMethodName)
          .call([keysClass.property(translation.keyVariable)]).code;
  }

  void _buildSimpleInterceptorMethod(
      MethodBuilder methodBuilder, Interceptor interceptor) {
    methodBuilder
      ..type = MethodType.getter
      ..body = _helper.property(interceptor.name).call([
        (isInHelper ? translate : innerHelper.property(_translateMethodName))
            .call([
          refer(_keysClassName).property(translation.keyVariable),
        ]),
      ]).code;
  }

  void _buildParametrizedInterceptorMethod(
      MethodBuilder methodBuilder, Interceptor interceptor) {
    var interceptorMethod = _helper.property(interceptor.name);
    var methodParameters = interceptor.element.parameters
        .skip(1)
        .map((e) => Parameter((pb) => pb
          ..name = e.name
          ..type = refer(e.type.displayName)))
        .toList();

    var internalParameters = interceptor.element.parameters
        .skip(1)
        .map((e) => refer(e.name))
        .toList();

    methodBuilder
      ..requiredParameters.addAll(methodParameters)
      ..types.addAll(interceptor.element.typeParameters
          .map((tp) => refer(tp.name))
          .toList())
      ..body = interceptorMethod
          .call(
            List()
              ..add(_helper.property(_translateMethodName).call([
                refer(_keysClassName).property(translation.keyVariable),
              ]))
              ..addAll(internalParameters),
          )
          .code;
  }

  List<Method> _getChildMethods(List<Node> children, List<Class> classList,
      List<Interceptor> interceptors, Reference helperRef,
      {String pascalPrefix = "", bool parentIsRoot = false}) {
    List<Method> childMethods = [];
    for (Node child in children) {
      List<Method> childFields = child.generateClasses(
          classList, interceptors, helperRef,
          pascalPrefix: pascalPrefix + _pascalName);
      if (childFields != null) childMethods.addAll(childFields);
    }
    return childMethods;
  }

  Class _generateNodeClass(List<Method> childMethods, Reference helperRef) {
    return Class((classBuilder) {
      classBuilder
        ..name = _privatePascalPrefixName
        ..fields.add(Field((fieldBuilder) => fieldBuilder
          ..modifier = FieldModifier.final$
          ..type = helperRef
          ..name = _innerHelper))
        ..constructors.add(Constructor((constructorBuilder) =>
            constructorBuilder
              ..requiredParameters
                  .add(Parameter((parameterBuilder) => parameterBuilder
                    ..toThis = true
                    ..name = _innerHelper))))
        ..fields.addAll(childMethods
            .where((child) => child.returns != stringType)
            .map((child) => Field((fieldBuilder) => fieldBuilder
              ..name = "_${child.name}"
              ..type = child.returns))
            .toList())
        ..methods.addAll(childMethods);
    });
  }
}
