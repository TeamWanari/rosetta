import 'package:code_builder/code_builder.dart';
import 'package:rosetta_generator/src/consts.dart';
import 'package:rosetta_generator/src/entities/interceptor.dart';
import 'package:rosetta_generator/src/tree/abstract/node.dart';
import 'package:rosetta_generator/src/tree/abstract/visitor.dart';
import 'package:rosetta_generator/src/tree/implementation/node.dart';
import 'package:rosetta_generator/src/tree/implementation/product.dart';
import 'package:rosetta_generator/src/utils.dart';

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
    if (node.isLeaf()) {
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

  void _buildGetterMethod(TranslationNode node, MethodBuilder methodBuilder) {
    methodBuilder
      ..type = MethodType.getter
      ..body = node.helper
          .property(strTranslateMethodName)
          .call([refKeysClass.property(node.translation.keyVariable)]).code;
  }

  void _buildSimpleInterceptorMethod(TranslationNode node,
      MethodBuilder methodBuilder, Interceptor interceptor) {
    methodBuilder
      ..type = MethodType.getter
      ..body = node.helper.property(interceptor.name).call([
        (node.isInHelper
                ? refTranslate
                : refInnerHelper.property(strTranslateMethodName))
            .call([
          refer(strKeysClassName).property(node.translation.keyVariable),
        ]),
      ]).code;
  }

  void _buildParametrizedInterceptorMethod(TranslationNode node,
      MethodBuilder methodBuilder, Interceptor interceptor) {
    var interceptorMethod = node.helper.property(interceptor.name);
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
              ..add(node.helper.property(strTranslateMethodName).call([
                refer(strKeysClassName).property(node.translation.keyVariable),
              ]))
              ..addAll(internalParameters),
          )
          .code;
  }

  List<Method> _getChildMethods(TranslationNode node,
      {String pascalPrefix = "", bool parentIsRoot = false}) {
    List<Method> childMethods = [];
    for (Node child in node.children) {
      List<Method> childFields =
          _generateClasses(child, pascalPrefix: pascalPrefix + node.pascalName);
      if (childFields != null) childMethods.addAll(childFields);
    }
    return childMethods;
  }

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
