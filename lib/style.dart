// @dart=2.9
class Style {
  final int id;
  final String name;
  final int score;

  Style({this.id, this.name, this.score});

  Style.fromMap(Map<String, dynamic> res)
      : this.id = res["_id"],
        this.name = res["name"],
        this.score = res["score"];
}
