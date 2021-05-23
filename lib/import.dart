import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'ascent.dart';
import 'crag.dart';
import 'route.dart';
import 'style.dart';

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
    List<Ascent> ascents = [];
    for (var i = 0; i < lines.length; i++) {
      var strings = lines[i].split("\t");
      if (strings.length == 10) {
        String routeName = strings[0];
        String routeGrade = strings[1];
        String cragName = strings[2];
        String sector = strings[3];
        String cragCountry = strings[4];
        int style = int.parse(strings[5]);
        int attempts = int.parse(strings[6]);
        DateTime date = DateTime.parse(strings[7]);
        String comments = strings[8];
        int stars = int.parse(strings[9]);

        Crag crag = new Crag(name: cragName, country: cragCountry);
        Route route = new Route(name: routeName, grade: routeGrade, crag: crag, sector: sector);
        var ascent = new Ascent(route: route, style: Style(id: style), attempts: attempts, date: date, comment: comments, stars: stars);
        ascents.add(ascent);
      }
    }
    return ascents;
  }
}
