import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'model/ascent.dart';

class CsvImporter {
  Future<List<Ascent>?> readFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      final contents = await file.readAsString();
      return parse(contents);
    } else {
      return null;
    }
  }

  List<Ascent> parse(String contents) {
    LineSplitter splitter = LineSplitter();
    var lines = splitter.convert(contents);
    List<Ascent> ascents = lines.map((line) => Ascent.fromString(line)).toList();
    return ascents;
  }

  /// Opens a save dialog and writes the ascents as CSV.
  /// Returns true if saved, false if cancelled.
  Future<bool> saveFile(List<Ascent> ascents) async {
    StringBuffer buf = StringBuffer();
    for (Ascent a in ascents) {
      buf.write(a.encode());
    }
    var bytes = utf8.encode(buf.toString());
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export ascents',
      fileName: 'ascent-export.csv',
      bytes: Uint8List.fromList(bytes),
    );
    return path != null;
  }

  List<Ascent> parseEightAJson(String data) {
    List list = json.decode(data);
    return list.map((item) => Ascent.fromJson(item)).toList();
  }
}
