import 'package:code_builder/code_builder.dart';
import 'package:rosetta_generator/src/consts.dart';
import 'package:rosetta_generator/src/entities/interceptor.dart';
import 'package:rosetta_generator/src/tree/abstract/node.dart';
import 'package:rosetta_generator/src/tree/abstract/visitor.dart';
import 'package:rosetta_generator/src/tree/entities/product.dart';
import 'package:rosetta_generator/src/tree/implementation/node.dart';
import 'package:rosetta_generator/src/utils.dart';

class TranslationVisitor extends Visitor<TranslationProduct, TranslationNode> {
  List<Class> classList = [];
  List<Method> methodList = [];
  Map<String, Spec> resolutionMap = Map();
  List<Interceptor> interceptors;
  Reference helperRef;
  String keysClassName;
  Reference keysClassRef;

  TranslationVisitor(this.keysClassName,
      {List<Interceptor> interceptors,
      Reference helperRef,
      String keyClassName}) {
    keysClassRef = Reference(keysClassName);
    this.interceptors = interceptors == null ? [] : interceptors;
    this.helperRef = helperRef == null ? Reference("") : helperRef;
  }

  @override
  TranslationProduct visit(TranslationNode node) {
    _generate(node);
    return TranslationProduct(
        helperMethods: methodList,
        translationClasses: classList,
        resolutionMap: resolutionMap);
  }

  ///The _generateClasses method returns with the methodList and as a
  ///SIDE EFFECT it also adds the necessary elements to the classList.

  void _generate(TranslationNode node) {
    classList.clear();
    methodList = _generateClasses(node, pascalPrefix: "");
  }

  ///Recursively visits each Node and returns the required methods.
  ///SIDE EFFECT: Adds the necessary elements to the classList
  ///
  ///The methods will end up in the Helper and the generated Classes
  ///must be added to the file.

  List<Method> _generateClasses(TranslationNode node,
      {String pascalPrefix = ""}) {
    if (node.isLeaf()) {
      return [_generateLeafMethod(node)];
    } else {
      List<Method> childMethods =
          _getChildMethods(node, pascalPrefix: pascalPrefix);

      if (!node.isRoot) {
        ///If it's not the Root Node, then a Class should be generated for it
        ///and the methods passed upwards.
        classList.add(_generateNodeClass(node, childMethods));
        return [_generateNodeMethod(node)];
      } else {
        ///If it's the Root Node, then we just pass the methods, that should
        ///be in the Helper.
        return childMethods;
      }
    }
  }

  ///Returns the Getter trough which the Class associated with the Node
  ///should be accessed in the ascendant Class.
  Method _generateNodeMethod(TranslationNode node) {
    return Method(
      (mb) => mb
        ..name = node.camelName
        ..type = MethodType.getter
        ..lambda = true
        ..body = refer("_${node.camelName}")
            .assignNullAware(refer(node.privatePascalPrefixName)
                .newInstance([node.isInHelper ? refThis : refInnerHelper]))
            .code
        ..returns = refer(node.privatePascalPrefixName),
    );
  }

  ///Returns the Getter/Interceptor trough which the value of the Node
  ///should be accessed in the ascendant Class.
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
      ..name = node.camelName
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

  ///Generates a simple Getter for a given Node.
  void _buildGetterMethod(TranslationNode node, MethodBuilder methodBuilder) {
    methodBuilder
      ..type = MethodType.getter
      ..body = node.helper
          .property(strTranslateMethodName)
          .call([keysClassRef.property(node.translation.keyVariable)]).code;

    resolutionMap.addEntries([
      MapEntry(
          node.translation.key,
          refTranslate
              .call([keysClassRef.property(node.translation.keyVariable)]).code)
    ]);
  }

  ///Generates a Simple Interceptor method for a given Node.
  void _buildSimpleInterceptorMethod(TranslationNode node,
      MethodBuilder methodBuilder, Interceptor interceptor) {
    if (node.isInHelper) {
      methodBuilder
        ..type = MethodType.getter
        ..body = refResolve
            .call([keysClassRef.property(node.translation.keyVariable)]).code;
    } else {
      methodBuilder
        ..type = MethodType.getter
        ..body = refInnerHelper
            .property(strResolveMethodName)
            .call([keysClassRef.property(node.translation.keyVariable)]).code;
    }

    resolutionMap.addEntries([
      MapEntry(
          node.translation.key,
          refer(interceptor.name).call([
            refTranslate.call(
                [refer(keysClassName).property(node.translation.keyVariable)])
          ]))
    ]);
  }

  ///Generates a Parametrized Interceptor method for a
  ///given node, if it has a matching.
  void _buildParametrizedInterceptorMethod(TranslationNode node,
      MethodBuilder methodBuilder, Interceptor interceptor) {
    var methodParameters = interceptor.element.parameters
        .skip(1)
        .map((e) => Parameter((pb) => pb
          ..name = e.name
          ..type = refer(e.type.getDisplayString(withNullability: false))))
        .toList();

    var internalParameters = interceptor.element.parameters
        .skip(1)
        .map((e) => refer(e.name))
        .toList();
    if (node.isInHelper) {
      methodBuilder
        ..requiredParameters.addAll(methodParameters)
        ..types.addAll(interceptor.element.typeParameters
            .map((tp) => refer(tp.name))
            .toList())
        ..body = refResolve
            .call([keysClassRef.property(node.translation.keyVariable)])
            .call(internalParameters)
            .code;
    } else {
      methodBuilder
        ..requiredParameters.addAll(methodParameters)
        ..types.addAll(interceptor.element.typeParameters
            .map((tp) => refer(tp.name))
            .toList())
        ..body = refInnerHelper
            .property(strResolveMethodName)
            .call([keysClassRef.property(node.translation.keyVariable)])
            .call(internalParameters)
            .code;
    }

    resolutionMap.addEntries([
      MapEntry(
          node.translation.key,
          Method((mb) => mb
            ..lambda = true
            ..requiredParameters.addAll(methodParameters)
            ..body = refer(interceptor.name)
                .call(
                  []
                    ..add(refer(strTranslateMethodName).call([
                      refer(keysClassName)
                          .property(node.translation.keyVariable),
                    ]))
                    ..addAll(internalParameters),
                )
                .code))
    ]);
  }

  ///Return the Getters and interceptors that should be in the Class
  ///associated with the Node, based on its children.
  List<Method> _getChildMethods(TranslationNode node,
      {String pascalPrefix = ""}) {
    List<Method> childMethods = [];
    for (Node child in node.children) {
      List<Method> childFields =
          _generateClasses(child, pascalPrefix: pascalPrefix + node.pascalName);
      if (childFields != null) childMethods.addAll(childFields);
    }
    return childMethods;
  }

  ///Generates a Class associated with the given Node.
  ///This will be called for each Non-Leaf Node, except the Root.
  ///(The contents of the Root Class goes in the Helper.)
  Class _generateNodeClass(TranslationNode node, List<Method> childMethods) {
    return Class((classBuilder) {
      classBuilder
        ..name = node.privatePascalPrefixName
        ..fields.add(Field((fieldBuilder) => fieldBuilder
          ..modifier = FieldModifier.final$
          ..type = helperRef
          ..name = strInnerHelper))
        ..constructors.add(Constructor((constructorBuilder) =>
            constructorBuilder
              ..requiredParameters
                  .add(Parameter((parameterBuilder) => parameterBuilder
                    ..toThis = true
                    ..name = strInnerHelper))))
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
