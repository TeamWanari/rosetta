import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:rosetta_generator/src/validations.dart';

///Represents an interceptor with a given filter.
///
///Defines how the filtered translation string should be accessed.

class Interceptor {
  MethodElement element;

  Reference get returns =>
      refer(element.returnType.getDisplayString(withNullability: false));

  String get name => element.name;

  RegExp? filter;

  List<Parameter> get parameterList => element.parameters
      .map((pe) => Parameter((pb) => pb
        ..name = pe.name
        ..type = refer(pe.type.getDisplayString(withNullability: false))))
      .toList();

  Interceptor({required this.element}) {
    checkInterceptorFormat(this.element);

    var annotation = interceptorTypeChecker.firstAnnotationOfExact(element);
    String? filterString = annotation!.getField("filter")!.toStringValue();

    if (filterString != null) {
      filter = RegExp(filterString);
    }
  }
}
