
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

  Style.fromEightACode(String? code) {
    var styles = DatabaseHelper.styles;
    String styleName = "Onsight";
    switch (code) {
      case "fl":
        styleName = "Flash";
        break;
      case "rp":
        styleName = "Redpoint";
        break;
      case "tr":
        styleName = "Toprope";
        break;
    }
    var s = styles.firstWhere((element) => element.name == styleName);
    id = s.id;
    name = s.name;
    shortName = s.shortName;
    score = s.score;
  }
}
