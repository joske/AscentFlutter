import 'dart:async';

import 'package:ascent/crag.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'ascent.dart';
import 'style.dart';

class DatabaseHelper {
  static Database _db;

  static int get _version => 1;

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
    var crag = ascent.route.crag;
    int cragId = crag.id;
    if (cragId == null) {
      cragId = await getCrag(crag.name, crag.country);
      if (cragId == null) {
        cragId = await addCrag(crag);
      } else {
        print("got existing crag ('${crag.name}', '${crag.country}') with id $cragId");
      }
    } else {
      // crag id but no name? probably import scenario
      if (crag.name == null) {
        List<Crag> list = await getCragFromId(cragId);
        if (list.isNotEmpty) {
          crag.name = list[0].name;
          crag.country = list[0].country;
          print("got existing crag ('${crag.name}', '${crag.country}') with id $cragId");
        }
      }
    }
    crag.id = cragId;
    var map = ascent.route.toMap();
    map.putIfAbsent("crag_id", () => cragId);
    int id = await _db.insert("routes", map);
    print("inserted route ${ascent.route.name} at id $id");
    ascent.route.id = id;
    return id;
  }

  static Future<int> addAscent(Ascent ascent) async {
    int id = -1;
    await init();
    var routeId = ascent.route.id;
    if (routeId == null) {
      await _addRoute(ascent);
    }
    var map = ascent.toMap();
    map.putIfAbsent("route_id", () => ascent.route.id);
    id = await _db.insert("ascents", map);
    print("inserted ascent ${ascent.route.name} at id $id");
    ascent.id = id;
    return id;
  }

  static Future<int> addCrag(Crag crag) async {
    await init();
    int id = await _db.insert("crag", crag.toMap());
    print("inserted crag ('${crag.name}', '${crag.country}') at id " + id.toString());
    crag.id = id;
    return id;
  }

  static Future<List<Crag>> getCrags() async {
    await init();
    final List<Map<String, Object>> queryResult = await _db.query('crag');
    return queryResult.map((e) => Crag.fromMap(e)).toList();
  }

  static Future<int> getCrag(String name, String country) async {
    await init();
    return Sqflite.firstIntValue(await _db.rawQuery('select _id from crag where name = ? and country = ?', [name, country]));
  }

  static Future<List<Crag>> getCragFromId(int id) async {
    await init();
    final List<Map<String, Object>> queryResult = await _db.rawQuery('select * from crag where _id = ? ', [id]);
    return queryResult.map((e) => Crag.fromMap(e)).toList();
  }

  static Future<int> getRoute(String name, String grade, int cragId) async {
    await init();
    if (cragId == null) {
      return Sqflite.firstIntValue(await _db.rawQuery('select _id from routes where name = ? and grade = ?', [name, grade]));
    } else {
      return Sqflite.firstIntValue(await _db.rawQuery('select _id from routes where name = ? and grade = ? and crag_id = ?', [name, grade, cragId]));
    }
  }

  static Future<List<String>> getGrades() async {
    await init();
    final List<Map<String, Object>> queryResult = await _db.query('grades');
    return queryResult.map((e) => e["grade"].toString()).toList();
  }

  static Future<List<Style>> getStyles() async {
    await init();
    final List<Map<String, Object>> queryResult = await _db.query('styles');
    return queryResult.map((e) => Style.fromMap(e)).toList();
  }

  static Future<List<Ascent>> getAscents(String query) async {
    await init();
    List<Map<String, Object>> queryResult;
    if (query != null) {
      query += '%';
      queryResult = await _db.query('ascent_routes', where: "route_name like ?", whereArgs: [query]);
    } else {
      queryResult = await _db.query('ascent_routes');
    }
    return queryResult.map((e) => Ascent.fromMap(e)).toList();
  }

  static Future<void> updateAscent(Ascent ascent) async {
    await init();
    await _db.update("routes", ascent.route.toMap(), where: '_id = ?', whereArgs: [ascent.route.id]);
    await _db.update("ascents", ascent.toMap(), where: '_id = ?', whereArgs: [ascent.id]);
  }

  static Future<void> deleteAscent(Ascent ascent) async {
    await init();
    await _db.rawDelete("delete from ascents where _id = ?", [ascent.id]);
  }

  static Future<void> clear() async {
    await init();
    await _db.rawDelete("delete from crag");
    await _db.rawDelete("delete from routes");
    await _db.rawDelete("delete from projects");
    await _db.rawDelete("delete from ascents");
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
