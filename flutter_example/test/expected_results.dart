List<String> getExpectedSeparatorTexts() {
  return [
    // simple results are filtered with "simple" trigger word
    "one",
    "one two",
    "one two three",
    "one 1 filtered",
    "one two 1 filtered",
    "one two three 1 filtered",
    "You have one point",
    "You have two points",
    "You have exactly this many points: 15"
  ];
}

List<String> getExpectedInterceptedTexts() {
  return [
    ">>> interceptor simple",
    ">>filtered>> interceptor filtered",
  ];
}
