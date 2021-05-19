import 'route.dart';

class Ascent {
  int id = -1;
  final Route route;
  final int attempts;
  final DateTime date;
  final int score;
  final int stars;
  final String comment;

  Ascent({required this.route, required this.attempts, required this.date, required this.score, required this.stars, required this.comment});

// "_id", "route_id", "route_grade", "attempts", "style_id", "date", "comment", "stars", "score", "modified", "eighta_id" },
  Ascent.fromMap(Map<String, dynamic> res)
      : id = res["_id"],
        route = res["route"],
        attempts = res["attempts"],
        date = res["date"],
        stars = res["stars"],
        comment = res["comment"],
        score = res["score"];

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["attempts"] = attempts;
    return map;
  }
}
