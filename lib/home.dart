// @dart=2.9
import 'package:ascent/import.dart';
import 'package:ascent/statistics.dart';
import 'package:ascent/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:intl/intl.dart';

import 'add_ascent_screen.dart';
import 'ascent.dart';
import 'cragscreen.dart';
import 'database.dart';
import 'overview.dart';

class MaterialHome extends StatefulWidget {
  MaterialHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MaterialHomeState createState() => new MaterialHomeState();
}

class MaterialHomeState extends State<MaterialHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SearchBar searchBar;
  DateFormat formatter = new DateFormat('yyyy-MM-dd');
  String query;

  MaterialHomeState() {
    searchBar = new SearchBar(
        inBar: false,
        setState: setState,
        clearOnSubmit: false,
        onSubmitted: onSubmitted,
        onChanged: onSubmitted,
        onCleared: () {
          query = null;
          setState(() => {});
        },
        onClosed: () {
          query = null;
          setState(() => {});
        },
        buildDefaultAppBar: buildAppBar);
  }

  Widget buildAppBar(BuildContext context) {
    return AppBar(title: Text(widget.title), actions: [searchBar.getSearchAction(context)]);
  }

  void onSubmitted(String value) {
    setState(() => query = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: searchBar.build(context),
      drawer: Drawer(
        child: buildDrawer(context),
      ),
      body: buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAscentScreen()),
          );
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    Future<List<Ascent>> ascents = DatabaseHelper.getAscents(query);
    return Column(
      children: [
        Container(
          color: Colors.grey[200],
          child: FutureBuilder(
              future: ascents,
              builder: (context, snapshot) {
                var len = snapshot != null && snapshot.data != null ? snapshot.data.length : 0;
                return ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("Ascents: $len")],
                    ),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      FutureBuilder(
                          future: DatabaseHelper.getScore(),
                          builder: (context, snapshot) {
                            var score = snapshot.data != null ? snapshot.data : "0";
                            return Text("Score: $score");
                          })
                    ]));
              }),
        ),
        Flexible(
          child: createScrollView(context, ascents, _buildRow),
        )
      ],
    );
  }

  Widget buildDrawer(BuildContext context) {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Ascent'),
        ),
        ListTile(
          title: Text('Crags'),
          onTap: () async {
            Navigator.of(context).pop(); // close drawer
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CragScreen()),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: Text('Summary'),
          onTap: () async {
            Navigator.of(context).pop();
            await overview();
            setState(() {});
          },
        ),
        ListTile(
          title: Text('Statistics'),
          onTap: () async {
            Navigator.of(context).pop();
            await statistics();
            setState(() {});
          },
        ),
        ListTile(
          title: Text('Import'),
          onTap: () async {
            Navigator.of(context).pop();
            await importData();
            setState(() {});
          },
        ),
        ListTile(
          title: Text('Export'),
          onTap: () async {
            Navigator.of(context).pop();
            await exportData();
          },
        ),
      ],
    );
  }

  Widget _buildRow(Ascent ascent) {
    return Card(
      child: ListTile(
        title: Text(
          "${formatter.format(ascent.date)}    ${ascent.route.grade}    ${ascent.style.name}    ${ascent.route.name}    ${ascent.score}",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                Text(
                  "${ascent.route.crag.name}    ${ascent.route.sector}    stars: ${ascent.stars}",
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            Container(
              child: Text(
                ascent.comment,
              ),
              alignment: Alignment.topLeft,
            ),
          ],
        ),
        trailing: createPopup(ascent, ['edit', 'delete'], [editAscent, deleteAscent]),
      ),
    );
  }

  void editAscent(Ascent ascent) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAscentScreen(passedAscent: ascent)),
    );
    setState(() {});
  }

  void deleteAscent(Ascent ascent) {
    DatabaseHelper.deleteAscent(ascent);
    setState(() {});
  }

  Future<void> importData() async {
    showProgressDialog(context, "Importing");
    try {
      var ascents = await CsvImporter().readFile();
      if (ascents.isNotEmpty) {
        await DatabaseHelper.clear();
        setState(() {});
        for (final a in ascents) {
          await DatabaseHelper.addAscent(a);
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Imported ${ascents.length} ascents"),
        ));
      }
    } catch (e) {
      print("failed to import $e");
      Navigator.pop(context);
      showAlertDialog(context, "Error", "Failed to Import data");
    }
    Navigator.pop(context);
  }

  Future<void> exportData() async {
    showProgressDialog(context, "Importing");
    try {
      var ascents = await DatabaseHelper.getAscents(null);
      CsvImporter().writeFile(ascents);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Exported ${ascents.length} ascents"),
      ));
    } catch (e) {
      print("failed to import $e");
      Navigator.pop(context);
      showAlertDialog(context, "Error", "Failed to Import data");
    }
    Navigator.pop(context);
  }

  overview() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OverviewScreen()),
    );
    setState(() {});
  }

  statistics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatisticsScreen()),
    );
    setState(() {});
  }
}
