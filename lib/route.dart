
import 'crag.dart';

class Route {
  int? id = -1;
  final String? name;
  final String? grade;
  final Crag? crag;
  final String? sector;
  final int? gradeScore;

  Route({this.id, this.name, this.grade, this.crag, this.sector, this.gradeScore});

  Route.fromMap(Map<String, dynamic> res)
      : id = res["_id"],
        name = res["name"],
        grade = res["grage"],
        crag = res["crag"],
        sector = res["sector"] != null ? res["sector"] : "",
        gradeScore = getScore(res["grade"]);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["name"] = name;
    map["grade"] = grade;
    map["crag_id"] = crag!.id;
    map["sector"] = sector;
    return map;
  }

  static int getScore(String? grade) {
    return 1000;
  }
}
