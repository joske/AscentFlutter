import 'crag.dart';

class Route {
  int id = -1;
  final String name;
  final String grade;
  final Crag crag;
  final String sector;
  final int gradeScore;

  Route({required this.name, required this.grade, required this.crag, required this.sector, required this.gradeScore});

  Route.fromMap(Map<String, dynamic> res)
      : id = res["_id"],
        name = res["name"],
        grade = res["grage"],
        crag = res["crag"],
        sector = res["sector"],
        gradeScore = res["gradeScore"];
}
