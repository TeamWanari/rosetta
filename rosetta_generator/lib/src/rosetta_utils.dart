part of 'rosetta_generator.dart';

Future<List<String>> getLanguages(String path) async {
  Directory directory = Directory(path);

  bool exists = await directory.exists();

  if (exists) {
    List<FileSystemEntity> entries =
        await directory.list(recursive: false, followLinks: true).toList();
    List<String> fileNames = List();

    for (FileSystemEntity entry in entries) {
      if (entry is File) fileNames.add(basename(entry.path));
    }
    return fileNames.map((name) => name.replaceAll(".json", "")).toList();
  }

  return List(0);
}

Future<List<String>> getKeys(String path, String name) async {
  File file = File('./$path/$name.json');

  bool exists = await file.exists();

  if (exists) {
    Map<String, dynamic> _result = json.decode(await file.readAsString());
    return _result.keys.toList();
  }

  return List(0);
}

Reference _localizationDelegateOf(String className) => TypeReference(
      (trb) => trb
        ..symbol = "LocalizationsDelegate"
        ..types.add(_typeOf(className)),
    );

Reference _futureOf(String className) => TypeReference(
      (trb) => trb
        ..symbol = "Future"
        ..types.add(_typeOf(className)),
    );

Reference _typeOf(String className) => TypeReference(
      (trb) => trb..symbol = className,
    );

Reference _mapOf(Reference keyType, Reference valueType) => TypeReference(
      (trb) => trb
        ..symbol = "Map"
        ..types.addAll([keyType, valueType]),
    );

Reference get boolType => TypeReference(
      (trb) => trb..symbol = "bool",
    );

Reference get dynamicType => TypeReference(
      (trb) => trb..symbol = "dynamic",
    );

Reference get stringType => TypeReference(
      (trb) => trb..symbol = "String",
    );

Reference get localeType => TypeReference(
      (trb) => trb..symbol = "Locale",
    );
