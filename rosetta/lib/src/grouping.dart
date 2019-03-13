class Grouping {
  final String separator;

  const Grouping.withSeparator({this.separator = "."})
      : assert(separator != null);
}
