import 'package:code_builder/code_builder.dart';

/// Contains the result of the TranslationVisitor.
///
/// The helperMethods list contains the getters, which should be added
/// to the TranslationHelper.
///
/// The translationClasses list contains the classes, that should also
/// be added, based on the intermediate nodes within the translation tree.

class TranslationProduct {
  final List<Method> helperMethods;
  final List<Class> translationClasses;

  TranslationProduct({this.helperMethods, this.translationClasses});
}
