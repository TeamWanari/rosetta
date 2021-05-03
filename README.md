# Rosetta

[![travis](https://img.shields.io/travis/TeamWanari/rosetta.svg)](https://travis-ci.org/TeamWanari/rosetta)

This is a localization library to simplify Flutter localization with the help of code generation. It generates getter functions for the localized keyset, so you don't have to worry about typos in String keys any more. 

## Roadmap

### [v0.3.0](https://github.com/TeamWanari/rosetta/milestone/4)
> * [ ] Support for plurals
> * [ ] Key nesting
> * [ ] Desktop and web support
 
### [v0.4.0](https://github.com/TeamWanari/rosetta/milestone/5)
> * [ ] Null safety
> * [ ] Adding support for string arrays

### [v0.5.0](https://github.com/TeamWanari/rosetta/milestone/6)
> * [ ] Adding support for translaton context
> * [ ] Adding support for YAML localization files

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

[Source Code](https://github.com/TeamWanari/rosetta/tree/master/flutter_example)

An example showing how to setup `rosetta` and `rosetta_generator` inside a Flutter project.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/TeamWanari/rosetta/issues).  
If you fixed a bug or implemented a new feature, please send a [pull request](https://github.com/TeamWanari/rosetta/pulls).
