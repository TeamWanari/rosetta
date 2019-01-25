/// Marks an instance method, which should be used as an interceptor on all
/// matching translation values.
///
/// Should only be used in @[Stone] annotated classes. Otherwise the generator
/// will ignore it.
class Intercept {
  /// The regular expression string, which will be used to find translation
  /// keys, which should be intercepted by the annotated method.
  ///
  /// (Optional)
  final String filter;

  const Intercept._({
    this.filter,
  });

  /// Declares the annotated method as a simple interceptor, which will be
  /// applied to all getter methods generated for the provided translations.
  ///
  /// The annotated method should return an instance of [String].
  ///
  /// If the annotated method declares parameters, then all the getter methods
  /// will be replaced by normal methods, which will have a parameter list
  /// matching the interceptor's parameters.
  factory Intercept.simple() => Intercept._();

  /// Declares the annotated method as a conditional interceptor, which will be
  /// applied to all getter methods generated for the provided translations,
  /// if any of the referred localized translation matches the given [filter]
  /// regular expression.
  ///
  /// The first parameter of the annotated method must be a type of [String].
  ///
  /// The annotated method should return an instance of [String].
  ///
  /// If the annotated method declares additional parameters, then all the
  /// related getter methods will be replaced by normal methods, which will
  /// have a parameter list matching the interceptor's parameters with the
  /// exception of the first [String] parameter.
  factory Intercept.withFilter({String filter}) => Intercept._(filter: filter);
}
