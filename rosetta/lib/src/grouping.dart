/// You can use an instance of the class to hold the configuration
/// for a [Stone] to describe how the keys should be divided into sub-keys.

class Grouping {
  /// The [String] which will be used to split the keys into sub-keys.
  final String separator;

  /// A named constructor, which can be used to create a [Grouping] with the
  /// desired [separator].
  ///
  /// When used, a [separator] must be provided or else it will throw
  /// an exception
  ///
  /// The default [separator] is a '.' character.
  const Grouping.withSeparator({this.separator = "."})
      : assert(separator != null);
}
