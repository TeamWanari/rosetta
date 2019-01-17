/// An annotation that generates code for translation Jsons
/// located in the directory described in [Stone.path] parameter.
class Stone {
  /// Translation files' directory path. The translation files
  /// should be named according to the [Locale.languageCode] of
  /// the represented [Locale].
  /// Must not be [null].
  final String path;

  /// Create an annotation that will generate the Helper and
  /// Delegate classes for the translations located at [path].
  const Stone({
    this.path,
  }) : assert(path != null);
}
