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
