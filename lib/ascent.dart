// @dart=2.9
import 'package:intl/intl.dart';

import 'crag.dart';
import 'route.dart';
import 'style.dart';

class Ascent {
  int id = -1;
  Route route;
  int attempts;
  DateTime date;
  int score;
  int stars;
  Style style;
  String comment;
  int eightAId;

  DateFormat formatter = new DateFormat('yyyy-MM-dd');

  Ascent({this.route, this.attempts, this.date, this.score, this.stars, this.comment, this.style});

// "_id", "route_id", "route_grade", "attempts", "style_id", "date", "comment", "stars", "score", "modified", "eighta_id" },
  Ascent.fromMap(Map<String, dynamic> res)
      : id = res["_id"],
        route = Route(
            id: res["route_id"],
            name: res["route_name"],
            grade: res["route_grade"],
            sector: res["sector"] != null ? res["sector"] : "",
            crag: Crag(id: res["crag_id"], name: res["crag_name"], country: res["crag_country"])),
        attempts = res["attempts"],
        date = DateTime.parse(res["date"]),
        stars = res["stars"],
        comment = res["comment"],
        style = Style(id: res["style_id"], name: res["style"], score: res["style_score"]),
        score = res["style_id"] != 5 && res["style_id"] != 7 ? res["score"] : 0;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null && id > 0) {
      map["_id"] = id;
    }
    map["date"] = date.toIso8601String();
    map["score"] = score;
    map["comment"] = comment;
    map["stars"] = stars;
    map["style_id"] = style.id;
    map["attempts"] = attempts;
    if (route.id != null) {
      map["route_id"] = route.id;
    }
    return map;
  }

  Ascent.fromString(String input) {
    var strings = input.split("\t");
    if (strings.length == 10) {
      String routeName = strings[0];
      String routeGrade = strings[1];
      String cragName = strings[2];
      String sector = strings[3];
      String cragCountry = strings[4];
      style = Style(id: int.parse(strings[5]));
      attempts = int.parse(strings[6]);
      date = DateTime.parse(strings[7]);
      comment = strings[8];
      stars = int.parse(strings[9]);

      Crag crag = new Crag(name: cragName, country: cragCountry);
      this.route = new Route(name: routeName, grade: routeGrade, crag: crag, sector: sector);
    }
  }

  String encode() {
    StringBuffer line = new StringBuffer();
    line.write(route.name);
    line.write("\t");
    line.write(route.grade);
    line.write("\t");
    line.write(route.crag.name);
    line.write("\t");
    line.write(route.sector);
    line.write("\t");
    line.write(route.crag.country);
    line.write("\t");
    line.write(style.id);
    line.write("\t");
    line.write(attempts);
    line.write("\t");
    line.write(formatter.format(date));
    line.write("\t");
    line.write(comment);
    line.write("\t");
    line.write(stars);
    line.write("\r\n");
    return line.toString();
  }

  Ascent.fromJson(Map<String, dynamic> res) {
    String area = res["areaName"];
    String cragName = res["cragName"];
    String sectorName = res["sectorSlug"];
    route = Route(
        name: res["zlaggableName"],
        grade: res["difficulty"],
        sector: area != null ? cragName : sectorName,
        crag: Crag(name: area != null ? area : cragName, country: res["countrySlug"]));
    date = DateTime.parse(res["date"]);
    stars = res["rating"];
    comment = res["comment"];
    String styleCode = res["type"];
    style = Style.fromEightACode(styleCode);
  }

  @override
  String toString() {
    return "Ascent($id ${route.name} ${route.grade} ${style.shortName} ${route.crag.name} ${route.sector} $score $stars ${formatter.format(date)} $comment";
  }
}
