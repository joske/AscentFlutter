import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:intl/intl.dart';

import 'add_crag-ios.dart';
import 'cragscreen.dart';
import 'import.dart';
import 'util.dart';
import 'add_ascent_screen.dart';
import 'ascent.dart';
import 'database.dart';
import 'overview.dart';

class CupertinoHome extends StatefulWidget {
  CupertinoHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  CupertinoHomeState createState() => new CupertinoHomeState();
}

class CupertinoHomeState extends State<CupertinoHome> {
  SearchBar searchBar;
  DateFormat formatter = new DateFormat('yyyy-MM-dd');
  String query;

  CupertinoHomeState() {
    searchBar = new SearchBar(
        inBar: false,
        setState: setState,
        clearOnSubmit: false,
        onSubmitted: onSubmitted,
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
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(items: buildTabBar(context)),
        tabBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return buildHomeScreen();
              break;
            case 1:
              return buildCragScreen();
              break;
            case 2:
              return buildStatsScreen();
              break;
            case 3:
              return buildStatsScreen();
              break;
            default:
              return buildHomeScreen();
          }
        });
  }

  Widget buildStatsScreen() {
    return CupertinoTabView(builder: (BuildContext context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Statistics'),
        ),
        child: OverviewScreen(),
      );
    });
  }

  Widget buildCragScreen() {
    return CupertinoTabView(builder: (BuildContext context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Crags'),
          trailing: CupertinoButton(
            child: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => CupertinoAddCragScreen()),
              );
              setState(() {});
            },
          ),
        ),
        child: CragScreen(),
      );
    });
  }

  Widget buildHomeScreen() {
    return CupertinoTabView(builder: (BuildContext context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title),
          trailing: CupertinoButton(
            child: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => AddAscentScreen()),
              );
              setState(() {});
            },
          ),
        ),
        child: buildBody(context),
      );
    });
  }

  Widget buildBody(BuildContext context) {
    Future<List<Ascent>> ascents = DatabaseHelper.getAscents(query);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 30),
          color: Colors.grey[200],
          child: FutureBuilder(
              future: ascents,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center();
                }
                var len = snapshot.data.length;
                return CupertinoListTile(
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

  Widget _buildRow(Ascent ascent) {
    return Card(
      child: CupertinoListTile(
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

  List<BottomNavigationBarItem> buildTabBar(BuildContext context) {
    return [
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.map), label: "Crags"),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar), label: "Statistics"),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: "Search"),
    ];
  }
}
