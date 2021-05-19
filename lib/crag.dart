class Crag {
  int id = -1;
  final String name;
  final String country;

  Crag({required this.name, required this.country});

  Crag.fromMap(Map<String, dynamic> res)
      : id = res["_id"],
        name = res["name"],
        country = res["country"];

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["name"] = name;
    map["country"] = country;
    return map;
  }
}