part of '../generator.dart';

class Interceptor {
  MethodElement element;

  Reference get returns => refer(element.returnType.name);

  String get name => element.name;

  RegExp filter;

  List<Parameter> get parameterList => element.parameters
      .map((pe) => Parameter((pb) => pb
        ..name = pe.name
        ..type = refer(pe.type.displayName)))
      .toList();

  Interceptor({this.element}) {
    checkInterceptorFormat(this.element);

    var annotation = _interceptorTypeChecker.firstAnnotationOfExact(element);
    String filterString = annotation.getField("filter").toStringValue();

    if (filterString != null) {
      filter = RegExp(filterString);
    }
  }
}
