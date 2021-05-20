import 'route.dart';

class Ascent {
  int id = -1;
  final Route route;
  final int attempts;
  final DateTime date;
  final int score;
  final int stars;
  final int style;
  final String comment;

  Ascent({this.route, this.attempts, this.date, this.score, this.stars, this.comment, this.style});

// "_id", "route_id", "route_grade", "attempts", "style_id", "date", "comment", "stars", "score", "modified", "eighta_id" },
  Ascent.fromMap(Map<String, dynamic> res)
      : id = res["_id"],
        route = Route(id: res["route_id"], name: res["route_name"], grade: res["route_grade"]),
        attempts = res["attempts"],
        date = DateTime.parse(res["date"]),
        stars = res["stars"],
        comment = res["comment"],
        score = res["score"],
        style = res["style_id"];

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["date"] = date.toIso8601String();
    map["score"] = score;
    map["comment"] = comment;
    map["stars"] = stars;
    map["style_id"] = 1;
    map["attempts"] = attempts;
    return map;
  }
}
