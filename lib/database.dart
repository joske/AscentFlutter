import 'dart:async';

import 'package:ascent/crag.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'ascent.dart';
import 'stats.dart';
import 'style.dart';

class DatabaseHelper {
  static Database? _db;

  static int get _version => 1;

  static final List<Style> styles = createStyleList();

  static Future<void> init() async {
    if (_db != null) {
      return;
    }

    try {
      var databasesPath = await getDatabasesPath();
      String _path = p.join(databasesPath, 'ascent.db');
      _db = await openDatabase(_path, version: _version, onCreate: onCreate);
    } catch (ex) {
      print(ex);
    }
  }

  static Future<int> _addRoute(Ascent ascent) async {
    await init();
    var crag = ascent.route!.crag!;
    int? cragId = crag.id;
    if (cragId == null) {
      cragId = await getCrag(crag.name, crag.country);
      if (cragId == null) {
        cragId = await addCrag(crag);
      } else {
        print(
            "got existing crag ('${crag.name}', '${crag.country}') with id $cragId");
      }
    } else {
      // crag id but no name? probably import scenario
      if (crag.name == null) {
        List<Crag> list = await getCragFromId(cragId);
        if (list.isNotEmpty) {
          crag.name = list[0].name;
          crag.country = list[0].country;
          print(
              "got existing crag ('${crag.name}', '${crag.country}') with id $cragId");
        }
      }
    }
    crag.id = cragId;
    var map = ascent.route!.toMap();
    map.putIfAbsent("crag_id", () => cragId);
    int id = await _db!.insert("routes", map);
    print("inserted route ${ascent.route!.name} at id $id");
    ascent.route!.id = id;
    return id;
  }

  static Future<int> addAscent(Ascent ascent) async {
    int id = -1;
    await init();
    int gradeScore = (await getGradeScore(ascent.route!.grade))!;
    int styleScore = (await getStyleScore(ascent.style!.id))!;
    ascent.score = gradeScore + styleScore;
    var routeId = ascent.route!.id;
    if (routeId == null) {
      await _addRoute(ascent);
    }
    var map = ascent.toMap();
    map.putIfAbsent("route_id", () => ascent.route!.id);
    id = await _db!.insert("ascents", map);
    print("inserted ascent ${ascent.route!.name} at id $id");
    ascent.id = id;
    return id;
  }

  static Future<int> addCrag(Crag crag) async {
    await init();
    int id = await _db!.insert("crag", crag.toMap());
    print("inserted crag ('${crag.name}', '${crag.country}') at id " +
        id.toString());
    crag.id = id;
    return id;
  }

  static Future<int> updateCrag(Crag crag) async {
    await init();
    var id = await _db!
        .update("crag", crag.toMap(), where: '_id = ?', whereArgs: [crag.id]);
    print("updated crag ('${crag.name}', '${crag.country}') at id " +
        id.toString());
    return id;
  }

  static Future<List<Crag>> getCrags() async {
    await init();
    final List<Map<String, Object?>> queryResult =
        await _db!.query('crag', orderBy: "name");
    return queryResult.map((e) => Crag.fromMap(e)).toList();
  }

  static Future<int?> getCrag(String? name, String? country) async {
    await init();
    return Sqflite.firstIntValue(await _db!.rawQuery(
        'select _id from crag where name = ? and country = ?',
        [name, country]));
  }

  static Future<List<Crag>> getCragFromId(int id) async {
    await init();
    final List<Map<String, Object?>> queryResult =
        await _db!.rawQuery('select * from crag where _id = ? ', [id]);
    return queryResult.map((e) => Crag.fromMap(e)).toList();
  }

  // static Future<int?> getRoute(String name, String grade, int cragId) async {
  //   await init();
  //   if (cragId == null) {
  //     return Sqflite.firstIntValue(await _db!.rawQuery('select _id from routes where name = ? and grade = ?', [name, grade]));
  //   } else {
  //     return Sqflite.firstIntValue(await _db!.rawQuery('select _id from routes where name = ? and grade = ? and crag_id = ?', [name, grade, cragId]));
  //   }
  // }

  static Future<List<String>> getGrades() async {
    await init();
    final List<Map<String, Object?>> queryResult = await _db!.query('grades');
    return queryResult.map((e) => e["grade"].toString()).toList();
  }

  static List<Style> getStyles() {
    return styles;
  }

  static Future<List<Ascent>> getAscents(String? routeName) async {
    String? where;
    List<Object>? args;
    if (routeName != null) {
      where = "route_name like ?";
      args = [routeName + "%"];
    }
    return getAscentsWhere(where, args);
  }

  static Future<List<String>> getYearsWithAscents() async {
    await init();
    List<Map<String, Object?>> res = await _db!
        .query('ascent_routes', columns: ["date"], orderBy: "date ASC");
    DateTime firstYear = DateTime.parse(res.first["date"] as String);
    int numYears = new DateTime.now().year - firstYear.year + 1;
    var list = List.generate(numYears, (i) => (firstYear.year + i).toString());
    list.insert(0, "All");
    return list;
  }

  static Future<List<Ascent>> getAscentsForCrag(
      String? year, int cragId) async {
    await init();
    String where;
    List<Object?> args = List.empty(growable: true);
    where = "style_id not null"; // to simplify the append of the criteria ("*")
    if (cragId > 0) {
      where += " and crag_id = ?";
      args.add(cragId);
    }
    if (year != "All") {
      where += " and strftime('%Y', date) = ?";
      args.add(year);
    }
    return getAscentsWhere(where, args);
  }

  static Future<List<Ascent>> getAscentsWhere(
      String? where, List<Object?>? args) async {
    await init();
    List<Map<String, Object?>> queryResult;
    if (where != null) {
      queryResult = await _db!.query('ascent_routes',
          where: where, whereArgs: args, orderBy: "date desc");
    } else {
      queryResult = await _db!.query('ascent_routes', orderBy: "date desc");
    }
    return queryResult.map((e) => Ascent.fromMap(e)).toList();
  }

  static Future<List<Ascent>> getTop10Last12Months() async {
    return getTop10Where("julianday(date('now'))- julianday(date) < 365");
  }

  static Future<List<Ascent>> getTop10AllTime() async {
    return getTop10Where(null);
  }

  static Future<List<Ascent>> getTop10Where(String? where) async {
    await init();
    List<Map<String, Object?>> queryResult;
    String notTried = "style_id <> 7 and style_id <> 5";
    if (where != null && where.isNotEmpty) {
      where = where + " and " + notTried;
    } else {
      where = notTried;
    }
    queryResult = await _db!.query('ascent_routes',
        orderBy: "score desc, date desc", where: where, limit: 10);
    return queryResult.map((e) => Ascent.fromMap(e)).toList();
  }

  static Future<int> getTop10ScoreAllTime() async {
    return getTop10ScoreWhere(null);
  }

  static Future<int> getTop10ScoreLast12Months() async {
    return getTop10ScoreWhere("julianday(date('now'))- julianday(date) < 365");
  }

  static Future<int> getTop10ScoreWhere(String? where) async {
    await init();
    List<Map<String, Object?>> queryResult;
    String notTried = "style_id <> 7 and style_id <> 5";
    if (where != null && where.isNotEmpty) {
      where = where + " and " + notTried;
    } else {
      where = notTried;
    }
    queryResult = await _db!.query('ascent_routes',
        columns: ["score"],
        orderBy: "score desc, date desc",
        where: where,
        limit: 10);
    int score =
        queryResult.map((e) => e["score"]).fold(0, (p, n) => p + (n as int));
    return score;
  }

  static Future<void> updateAscent(Ascent ascent) async {
    await init();
    int gradeScore = (await getGradeScore(ascent.route!.grade))!;
    int styleScore = (await getStyleScore(ascent.style!.id))!;
    ascent.score = gradeScore + styleScore;
    await _db!.update("routes", ascent.route!.toMap(),
        where: '_id = ?', whereArgs: [ascent.route!.id]);
    await _db!.update("ascents", ascent.toMap(),
        where: '_id = ?', whereArgs: [ascent.id]);
  }

  static Future<void> deleteAscent(Ascent ascent) async {
    await init();
    await _db!.rawDelete("delete from ascents where _id = ?", [ascent.id]);
  }

  static Future<int?> getGradeScore(String? grade) async {
    await init();
    return Sqflite.firstIntValue(await _db!.query("grades",
        columns: ["score"], where: "grade = ?", whereArgs: [grade]));
  }

  static Future<String> getScore() async {
    await init();
    var result = await _db!.query("ascent_routes",
        columns: ["sum(score)"],
        where:
            "style_id <> 7 and style_id <> 5 and julianday(date('now'))- julianday(date) < 365",
        orderBy: "score desc, date desc",
        limit: 10);
    var score12m = Sqflite.firstIntValue(result);
    if (score12m == null) {
      score12m = 0;
    }
    result = await _db!.query("ascent_routes",
        columns: ["score"],
        where: "style_id <> 7 and style_id <> 5 and score is not null",
        orderBy: "score desc, date desc",
        limit: 10);
    var allTime = 0;
    if (result.isNotEmpty) {
      // sum(score) does not seem to honor the limit, so it sums ALL scores and you get a ridiculous value
      // strangely the above code for last 12 months DOES correctly limit to first 10 ascents :-/
      // implement it here as a map() + fold()
      allTime = result.map((e) => e["score"]).fold(0, (p, n) => p + (n as int));
    }
    result = await _db!.query("ascent_routes",
        columns: ["score"],
        where:
            "strftime('%Y', date) = strftime('%Y', date('now')) and style_id <> 7 and style_id <> 5",
        orderBy: "score desc, date desc",
        limit: 10);
    var year = 0;
    // sum(score) does not seem to honor the limit, so it sums ALL scores and you get a ridiculous value
    // strangely the above code for last 12 months DOES correctly limit to first 10 ascents :-/
    // implement it here as a map() + fold()
    year = result.map((e) => e["score"]).fold(0, (p, n) => p + (n as int));
    return "$score12m - All Time: $allTime - Year: $year";
  }

  static Future<int?> getStyleScore(int? style) async {
    await init();
    return Sqflite.firstIntValue(await _db!.query("styles",
        columns: ["score"], where: "_id = ?", whereArgs: [style]));
  }

  static int calculateScore(
      int attempts, int style, int gradeScore, int styleScore) {
    int totalScore = gradeScore + styleScore;
    if (style == 2 && attempts == 2) {
      totalScore += 2;
    }
    return totalScore;
  }

  static Future<List<Stats>> getStats(int year, int cragId) async {
    await init();
    var done = await _db!.query("ascent_routes",
        columns: ["route_grade", "count(*) as done"],
        where: "style_id = 1 or style_id = 2 or style_id = 3",
        groupBy: "route_grade",
        orderBy: "route_grade desc");
    var tried = await _db!.query("ascent_routes",
        columns: ["route_grade", "count(*) as tried"],
        where: "style_id = 7",
        groupBy: "route_grade",
        orderBy: "route_grade desc");
    List<String> grades = await getGrades();
    List<Stats> stats = [];
    Map<String?, int?> doneMap = Map();
    Map<String?, int?> triedMap = Map();
    for (var e in done) {
      doneMap.putIfAbsent(e["route_grade"] as String?, () => e["done"] as int?);
    }
    for (var e in tried) {
      triedMap.putIfAbsent(
          e["route_grade"] as String?, () => e["tried"] as int?);
    }
    for (var g in grades.reversed) {
      int? done = 0;
      int? tried = 0;
      if (doneMap.containsKey(g)) {
        done = doneMap[g];
      }
      if (triedMap.containsKey(g)) {
        tried = triedMap[g];
      }
      if (done != 0 || tried != 0) {
        stats.add(Stats(grade: g, done: done, tried: tried));
      }
    }
    return stats;
  }

  static Future<void> clear() async {
    await init();
    await _db!.rawDelete("delete from crag");
    await _db!.rawDelete("delete from routes");
    await _db!.rawDelete("delete from projects");
    await _db!.rawDelete("delete from ascents");
  }

  static List<Style> createStyleList() {
    List<Style> list = [];
    list.add(Style(id: 1, name: "OnSight", shortName: "OS", score: 145));
    list.add(Style(id: 2, name: "Flash", shortName: "FL", score: 53));
    list.add(Style(id: 3, name: "Redpoint", shortName: "RP", score: 0));
    list.add(Style(id: 4, name: "Toprope", shortName: "TP", score: -52));
    list.add(Style(id: 5, name: "Repeat", shortName: "Rep", score: 0));
    list.add(Style(id: 6, name: "Multipitch", shortName: "MP", score: 0));
    list.add(Style(id: 7, name: "Tried", shortName: "AT", score: 0));
    return list;
  }

  static void onCreate(Database db, int version) async {
    await db.execute(
      "create table crag (_id integer primary key autoincrement, name text, country text)",
    );
    await db.execute(
      "create table styles (_id integer primary key, name text, short_name text, score int)",
    );
    await db.execute("insert into styles values (1, 'Onsight', 'OS', 145);");
    await db.execute("insert into styles values (2, 'Flash', 'FL', 53);");
    await db.execute("insert into styles values (3, 'Redpoint', 'RP', 0);");
    await db.execute("insert into styles values (4, 'Toprope', 'TP', -52);");
    await db.execute("insert into styles values (5, 'Repeat', 'Rep', 0);");
    await db.execute("insert into styles values (6, 'Multipitch', 'MP', 0);");
    await db.execute("insert into styles values (7, 'Tried', 'AT', 0);");
    await db.execute(
      "create table routes (_id integer primary key autoincrement, name text, grade text, crag_id integer, sector text)",
    );
    await db.execute(
      "create table ascents (_id integer primary key autoincrement, route_id int, date text, attempts int, style_id int, comment string, stars int, score int, eighta_id text, modified int)",
    );
    await db.execute(
      "create table projects (_id integer primary key autoincrement, route_id int, attempts int)",
    );
    await db.execute(
      "create table grades (grade text primary key, score number)",
    );
    await db.execute("insert into grades values ('3', 150);");
    await db.execute("insert into grades values ('4', 200);");
    await db.execute("insert into grades values ('5a', 250);");
    await db.execute("insert into grades values ('5b', 300);");
    await db.execute("insert into grades values ('5c', 350);");
    await db.execute("insert into grades values ('6a', 400);");
    await db.execute("insert into grades values ('6a+', 450);");
    await db.execute("insert into grades values ('6b', 500);");
    await db.execute("insert into grades values ('6b+', 550);");
    await db.execute("insert into grades values ('6c', 600);");
    await db.execute("insert into grades values ('6c+', 650);");
    await db.execute("insert into grades values ('7a', 700);");
    await db.execute("insert into grades values ('7a+', 750);");
    await db.execute("insert into grades values ('7b', 800);");
    await db.execute("insert into grades values ('7b+', 850);");
    await db.execute("insert into grades values ('7c', 900);");
    await db.execute("insert into grades values ('7c+', 950);");
    await db.execute("insert into grades values ('8a', 1000);");
    await db.execute("insert into grades values ('8a+', 1050);");
    await db.execute("insert into grades values ('8b', 1100);");
    await db.execute("insert into grades values ('8b+', 1150);");
    await db.execute("insert into grades values ('8c', 1200);");
    await db.execute("insert into grades values ('8c+', 1250);");
    await db.execute("insert into grades values ('9a', 1300);");
    await db.execute("insert into grades values ('9a+', 1350);");
    await db.execute("insert into grades values ('9b', 1400);");
    await db.execute("insert into grades values ('9b+', 1450);");
    await db.execute("insert into grades values ('9c', 1500);");
    await db.execute("insert into grades values ('9c+', 1550);");
    await db.execute("insert into grades values ('10a', 1600);");
    await db.execute("insert into grades values ('10a+', 1650);");
    await db.execute("insert into grades values ('10b', 1700);");
    await db.execute("insert into grades values ('10b+', 1750);");
    await db.execute("insert into grades values ('10c', 1800);");
    await db.execute("insert into grades values ('10c+', 1850);");
    await db.execute(
        "create view ascent_routes as select a._id as _id, r._id as route_id, r.name as route_name, r.grade as route_grade, a.attempts as attempts, a.comment as comment, s._id as style_id, s.short_name as style, s.score as style_score, a.stars as stars, a.date as date, r.crag_id as crag_id, c.country as crag_country, a.score as score, g.score as grade_score, c.name as crag_name, c._id as crag_id, a.eighta_id as eighta_id, a.modified as modified, r.sector as sector from ascents a inner join routes r on a.route_id = r._id inner join styles s on a.style_id = s._id inner join grades g on g.grade = r.grade inner join crag c on r.crag_id = c._id;");
    await db.execute(
        "create view project_routes as select p._id as _id, r.name as route_name, r.grade as route_grade, c.name as crag_name, p.attempts as attempts from projects p inner join routes r on p.route_id = r._id inner join crag c on r.crag_id = c._id;");
  }
}
