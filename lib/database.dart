import 'dart:async';

import 'package:ascent/crag.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'ascent.dart';

class AscentDatabase {
  static final AscentDatabase _instance = new AscentDatabase.internal();
  factory AscentDatabase() => _instance;

  static late Database _db;

  AscentDatabase.internal();

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await getDatabase();
    return _db;
  }

  Future<int> addAscent(Ascent ascent) async {
    var dbClient = await db;
    int res = await dbClient.insert("ascent_routes", ascent.toMap());
    return res;
  }

  Future<int> addCrag(Crag crag) async {
    var dbClient = await db;
    int res = await dbClient.insert("crag", crag.toMap());
    return res;
  }

  Future<List<Ascent>> getAscents() async {
    final List<Map<String, Object?>> queryResult = await _db.query('ascent_routes');
    return queryResult.map((e) => Ascent.fromMap(e)).toList();
  }

  Future<Database> getDatabase() async {
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'ascent_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
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
            "create view ascent_routes as select a._id as _id, r._id as route_id, r.name as route_name, r.grade as route_grade, a.attempts as attempts, a.comment as comment, s._id as style_id, s.short_name as style, s.score as style_score, a.stars as stars, a.date as date, r.crag_id as crag_id, a.score as score, g.score as grade_score, c.name as crag_name, c._id as crag_id, a.eighta_id as eighta_id, a.modified as modified, r.sector as sector from ascents a inner join routes r on a.route_id = r._id inner join styles s on a.style_id = s._id inner join grades g on g.grade = r.grade inner join crag c on r.crag_id = c._id;");
        await db.execute(
            "create view project_routes as select p._id as _id, r.name as route_name, r.grade as route_grade, c.name as crag_name, p.attempts as attempts from projects p inner join routes r on p.route_id = r._id inner join crag c on r.crag_id = c._id;");
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }
}
