import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'ascent.dart';

class CsvImporter {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/ascent-export.csv');
  }

  Future<List<Ascent>> readFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path);
      final contents = await file.readAsString();
      return parse(contents);
    } else {
      return null;
    }
  }

  List<Ascent> parse(String contents) {
    LineSplitter splitter = new LineSplitter();
    var lines = splitter.convert(contents);
    List<Ascent> ascents = [];
    for (var i = 0; i < lines.length; i++) {
      ascents.add(Ascent.fromString(lines[i]));
    }
    return ascents;
  }

  Future<void> writeFile(List<Ascent> ascents) async {
    final file = await _localFile;
    print("exporting to $file");
    StringBuffer buf = StringBuffer();
    for (Ascent a in ascents) {
      buf.write(a.encode());
    }
    file.writeAsString(buf.toString());
  }
}
