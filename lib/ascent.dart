import 'crag.dart';
import 'route.dart';
import 'style.dart';

class Ascent {
  int id = -1;
  final Route route;
  final int attempts;
  final DateTime date;
  final int score;
  final int stars;
  final Style style;
  final String comment;

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
        score = res["score"],
        style = Style(id: res["style_id"], name: res["style"], score: res["style_score"]);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["date"] = date.toIso8601String();
    map["score"] = score;
    map["comment"] = comment;
    map["stars"] = stars;
    map["style_id"] = style.id;
    map["attempts"] = attempts;
    return map;
  }
}
