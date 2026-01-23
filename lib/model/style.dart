import 'package:ascent/database.dart';

class Style {
  int? id;
  String? name;
  String? shortName;
  int? score;

  Style({this.id, this.name, this.score, this.shortName});

  Style.fromMap(Map<String, dynamic> res)
      : this.id = res["_id"],
        this.name = res["name"],
        this.shortName = res["short_name"],
        this.score = res["score"];

  Style.fromEightACode(String? code, {bool isProject = false}) {
    var styles = DatabaseHelper.styles;
    int styleId;
    if (isProject || code == null || code.isEmpty) {
      styleId = 7; // Tried/Project
    } else {
      switch (code) {
        case "os":
          styleId = 1; // OnSight
          break;
        case "f":
        case "fl":
          styleId = 2; // Flash
          break;
        case "rp":
          styleId = 3; // Redpoint
          break;
        case "tr":
        case "tp":
          styleId = 4; // Toprope
          break;
        default:
          styleId = 7; // Unknown = Tried
          break;
      }
    }
    var s = styles.firstWhere((element) => element.id == styleId);
    id = s.id;
    name = s.name;
    shortName = s.shortName;
    score = s.score;
  }
}
