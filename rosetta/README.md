# rosetta

[![Pub](https://img.shields.io/pub/v/rosetta.svg)](https://pub.dartlang.org/packages/rosetta)

This is a localization library to simplify Flutter localization with the help of code generation. It contains annotations to configure the `rosetta_generator`, which produces Helper classes for localization files, which can be used with `flutter_localizations` library. 

## Configuration

1. Add `rosetta` to `pubspec.yaml` under the `dependencies:` section.
The latest version is [![Pub](https://img.shields.io/pub/v/rosetta.svg)](https://pub.dartlang.org/packages/rosetta)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  rosetta: ^latest_version
```

2. Add [build_runner](https://github.com/dart-lang/build/tree/master/build_runner) and `rosetta_generator` under the `dev_dependencies:` section of the `pubspec.yaml` file.
The latest version is [![Pub](https://img.shields.io/pub/v/rosetta_generator.svg)](https://pub.dartlang.org/packages/rosetta_generator)

```yaml
dev_dependencies:  
  build_runner: '>=0.10.3 <1.2.0'
  rosetta_generator: ^latest_version
```

3. Add (or modify) the `build.yaml` file in the same folder as the `pubspec.yaml` and include the `rosetta` builder. Also if you placed your translation files outside the `lib` folder, you need to declare the path to be included in the generator build step.

```yaml
targets:
  $default:
    sources:        // These lines with comments show how to declare the additional folders
      include:      // which contain the translations. In our case the i18n folder. Sadly
        - i18n/**   // if declare the include block we need to specify all our source folders
        - lib/**    // also.
    builders:
      rosetta:
```

## Usage

In your library add the following import:

```dart
import 'package:rosetta/rosetta.dart';
```

Create a class containing two static members which will be used later for localization:

```dart
class Translation {
  static LocalizationsDelegate<Translation> delegate;

  static Translation of(BuildContext context) {
    return Localizations.of(context, Translation);
  }
}
```

Annotate the class with the **rosetta** `Stone` annotation. The **path** parameter should point to a directory containing the [languageCode].json localization files. 

```dart
@Stone(path: 'i18n')
class Translation {
  static LocalizationsDelegate<Translation> delegate;

  static Translation of(BuildContext context) {
    return Localizations.of(context, Translation);
  }
}
```

Include the part directive indicating the file that will be generated (typically the same file with a `.g` extension before `.dart`):

```dart
part 'rosetta_generator_example.g.dart';
```

Run build_runner:

```bash
flutter packages pub run build_runner build
```

**Note:** On first attempt to run this command you might encounter a conflict error. If so, please add the --delete-conflicting-outputs argument to your command:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```
(This additional argument allows the command to overwrite the `.g.dart` file if necessary.)

You can also use the `watch` command instead of `build`. This will generate your file when it's saved.

```bash
flutter packages pub run build_runner watch
```

This process will generate 3 classes (let's assume that the annotated class was called `Translation` as in the example above):
* **`_$Keys`**: Contains all your keys as static fields, this is currently for internal use.
* **`_$TranslationDelegate`**: This is an implementation of `LocalizationsDelegate<Translation>`, this should be passed to `MaterialApp` or `CupertinoApp` as a localization delegate. Also should be passed to the static `delegate` attribute of your original class.
* **`_$TranslationHelper`**: An abstract class, which is meant to be used as an abstract base or mixed in to your annotated class. Contains functions to access the localized strings for each key (ex.: `String get emptyList => _translate(_$Keys.emptyList);`). 

If you apply the generated classes you will end up something like this:

```dart
@Stone(path: 'i18n')
class Translation with _$TranslationHelper { // Generated mixin class or you can extend it also
  static LocalizationsDelegate<Translation> delegate = _$TranslationDelegate(); // Generated delegate

  static Translation of(BuildContext context) {
    return Localizations.of(context, Translation);
  }
}
```

You can now start using your localization logic:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
          	/// Returns a string repesented with a key "hello_there" in the localization files.
            Translation.of(context).helloThere,
          ),
        ),
      ),
      localizationsDelegates: [
      	/// Returns the generated delegate, which will setup the [Translation] instances.
        Translation.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale(SupportedLocales.english),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
```

The generated code backing the above functionality looks something like this (changes according to translation input):
```dart
class _$TranslationDelegate extends LocalizationsDelegate<Translation> {
  
  @override
  bool isSupported(Locale locale) => ["en"].contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<Translation> old) => false;

  @override
  Future<Translation> load(Locale locale) async {
    var translations = Translation();
    await translations.load(locale);
    return translations;
  }
}

class _$Keys {
  static final String helloThere = "hello_there";

  static final String seeYouSoon = "see_you_soon";
}

abstract class _$TranslationHelper {
  Map<String, String> _translations;

  Future<void> load(Locale locale) async {
    var jsonStr =
        await rootBundle.loadString("i18n/${locale.languageCode}.json");
    Map<String, dynamic> jsonMap = json.decode(jsonStr);
    _translations = jsonMap
        .map<String, String>((key, value) => MapEntry(key, value as String));
  }

  String _translate(String key) => _translations[key];

  String get helloThere => _translate(_$Keys.helloThere);
  String get seeYouSoon => _translate(_$Keys.seeYouSoon);
}
```
