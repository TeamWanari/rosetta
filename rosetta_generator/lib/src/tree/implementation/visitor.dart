part of '../../generator.dart';

class TranslationVisitor extends Visitor<TranslationProduct, TranslationNode> {
  List<Class> classList = [];
  List<Method> methodList = [];
  List<Interceptor> interceptors;
  Reference helperRef;

  TranslationVisitor({List<Interceptor> interceptors, Reference helperRef}) {
    this.interceptors = interceptors == null ? [] : interceptors;
    this.helperRef = helperRef == null ? Reference("") : helperRef;
  }

  @override
  TranslationProduct visit(TranslationNode node) {
    _generate(node);
    return TranslationProduct(
      helperMethods: methodList,
      translationClasses: classList,
    );
  }

  void _generate(TranslationNode node) {
    classList.clear();
    methodList = _generateClasses(node, pascalPrefix: "");
  }

  List<Method> _generateClasses(TranslationNode node,
      {String pascalPrefix = ""}) {
    if (node._isLeaf()) {
      return [_generateLeafMethod(node)];
    } else {
      List<Method> childMethods =
          _getChildMethods(node, pascalPrefix: pascalPrefix);

      if (!node.isRoot) {
        classList.add(_generateNodeClass(node, childMethods));
        return [_generateNodeMethod(node)];
      } else {
        return childMethods;
      }
    }
  }

  Method _generateNodeMethod(TranslationNode node) {
    return Method(
      (mb) => mb
        ..name = node._camelName
        ..type = MethodType.getter
        ..lambda = true
        ..body = refer("_${node._camelName}")
            .assignNullAware(refer(node._privatePascalPrefixName)
                .newInstance([node.isInHelper ? _this : innerHelper]))
            .code
        ..returns = refer(node._privatePascalPrefixName),
    );
  }

  Method _generateLeafMethod(TranslationNode node) {
    Iterable<Interceptor> matchResults = interceptors.where((i) =>
        i.filter == null ||
        node.translation.translations
            .where(i.filter.hasMatch)
            .toList()
            .isNotEmpty);

    Interceptor interceptor =
        matchResults.isNotEmpty ? matchResults.first : null;

    return Method((mb) => mb
      ..name = node._camelName
      ..lambda = true
      ..returns = stringType
      ..update((methodBuilder) {
        switch (interceptor?.parameterList?.length ?? 0) {
          case 0:
            _buildGetterMethod(node, methodBuilder);
            break;
          case 1:
            _buildSimpleInterceptorMethod(node, methodBuilder, interceptor);
            break;
          default:
            _buildParametrizedInterceptorMethod(
                node, methodBuilder, interceptor);
        }
      }));
  }

  void _buildGetterMethod(TranslationNode node, MethodBuilder methodBuilder) {
    methodBuilder
      ..type = MethodType.getter
      ..body = node._helper
          .property(_translateMethodName)
          .call([keysClass.property(node.translation.keyVariable)]).code;
  }

  void _buildSimpleInterceptorMethod(TranslationNode node,
      MethodBuilder methodBuilder, Interceptor interceptor) {
    methodBuilder
      ..type = MethodType.getter
      ..body = node._helper.property(interceptor.name).call([
        (node.isInHelper
                ? translate
                : innerHelper.property(_translateMethodName))
            .call([
          refer(_keysClassName).property(node.translation.keyVariable),
        ]),
      ]).code;
  }

  void _buildParametrizedInterceptorMethod(TranslationNode node,
      MethodBuilder methodBuilder, Interceptor interceptor) {
    var interceptorMethod = node._helper.property(interceptor.name);
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
              ..add(node._helper.property(_translateMethodName).call([
                refer(_keysClassName).property(node.translation.keyVariable),
              ]))
              ..addAll(internalParameters),
          )
          .code;
  }

  List<Method> _getChildMethods(TranslationNode node,
      {String pascalPrefix = "", bool parentIsRoot = false}) {
    List<Method> childMethods = [];
    for (Node child in node.children) {
      List<Method> childFields = _generateClasses(child,
          pascalPrefix: pascalPrefix + node._pascalName);
      if (childFields != null) childMethods.addAll(childFields);
    }
    return childMethods;
  }

  Class _generateNodeClass(TranslationNode node, List<Method> childMethods) {
    return Class((classBuilder) {
      classBuilder
        ..name = node._privatePascalPrefixName
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
