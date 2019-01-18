# Rosetta

[![travis](https://img.shields.io/travis/TeamWanari/rosetta.svg)](https://travis-ci.org/TeamWanari/rosetta)

This is a localization library to simplify Flutter localization with the help of code generation. It generates getter functions for the localized keyset, so you don't have to worry about typos in String keys any more. 

**IMPORTANT:**
* Dart2 is required to use this package.
* This project is designed for Flutter applications only
* This project is intended to be used with `flutter_localizations` library

## Rosetta Annotation

[![Pub](https://img.shields.io/pub/v/rosetta.svg)](https://pub.dartlang.org/packages/rosetta)

[Source Code](https://github.com/TeamWanari/rosetta/tree/master/rosetta)

The base package containing the annotations configuring the generator.

Import it into your pubspec `dependencies:` section.

## Rosetta Generator

[![Pub](https://img.shields.io/pub/v/rosetta_generator.svg)](https://pub.dartlang.org/packages/rosetta_generator)

[Source Code](https://github.com/TeamWanari/rosetta/tree/master/rosetta_generator)

The package providing the generator.

Import it into your pubspec `dev_dependencies:` section.

## Flutter Example

[Source Code](https://github.com/TeamWanari/rosetta/tree/master/example)

An example showing how to setup `rosetta` and `rosetta_generator` inside a Flutter project.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/TeamWanari/rosetta/issues).  
If you fixed a bug or implemented a new feature, please send a [pull request](https://github.com/TeamWanari/rosetta/pulls).