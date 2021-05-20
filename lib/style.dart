class Style {
  final int id;
  final String name;
  final int score;

  Style.fromMap(Map<String, dynamic> res)
      : this.id = res["_id"],
        this.name = res["name"],
        this.score = res["score"];
}
