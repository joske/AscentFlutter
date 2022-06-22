// @dart=2.9
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'ascent.dart';

class CsvImporter {
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
    List<Ascent> ascents = lines.map((line) => Ascent.fromString(line)).toList();
    return ascents;
  }

  Future<void> writeFile(List<Ascent> ascents) async {
    String directory = await FilePicker.platform.getDirectoryPath();

    if (directory != null) {
      File file = File(directory + "/ascent-export.csv");
      print("exporting to $file");
      StringBuffer buf = StringBuffer();
      for (Ascent a in ascents) {
        buf.write(a.encode());
      }
      file.writeAsString(buf.toString());
    }
  }

  List<Ascent> parseEightAJson(String data) {
    List list = json.decode(data);
    return list.map((item) => Ascent.fromJson(item)).toList();
  }
}
