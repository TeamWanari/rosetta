List<String> getExpectedSeparatorTexts() {
  return [
    // simple results are filtered with "simple" trigger word
    "one",
    "one two",
    "one two three",
    "one 1 filtered",
    "one two 1 filtered",
    "one two three 1 filtered",
    "Zero plus one is one"
  ];
}

List<String> getExpectedInterceptedTexts() {
  return [
    ">>> interceptor simple",
    ">>filtered>> interceptor filtered",
  ];
}
