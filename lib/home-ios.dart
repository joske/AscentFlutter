import 'package:ascent/statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_ascent_screen-ios.dart';
import 'add_crag-ios.dart';
import 'cragscreen.dart';
import 'importscreen-ios.dart';
import 'util.dart';
import 'model/ascent.dart';
import 'database.dart';
import 'overview.dart';

class CupertinoHome extends StatefulWidget {
  CupertinoHome({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  CupertinoHomeState createState() => new CupertinoHomeState();
}

class CupertinoHomeState extends State<CupertinoHome> {
  DateFormat formatter = new DateFormat('yyyy-MM-dd');
  String? query;
  TextEditingController? _textController;

  CupertinoHomeState() {
    _textController = TextEditingController();
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
            case 1:
              return buildCragScreen();
            case 2:
              return buildSummaryScreen();
            case 3:
              return buildStatsScreen();
            case 4:
              return buildImportScreen();
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
        child: StatisticsScreen(),
      );
    });
  }

  Widget buildSummaryScreen() {
    return CupertinoTabView(builder: (BuildContext context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Summary'),
        ),
        child: OverviewScreen(),
      );
    });
  }

  Widget buildImportScreen() {
    return CupertinoTabView(builder: (BuildContext context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Import/Export'),
        ),
        child: ImportScreen(),
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
              await showMaterialDialog(context, "Add Crag", CupertinoAddCragScreen(), [], 200, 400);
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
          middle: Text(widget.title!),
          trailing: CupertinoButton(
            child: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CupertinoAddAscentScreen()),
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
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 90),
          child: CupertinoSearchTextField(
            controller: _textController,
            onChanged: (String value) {
              setState(() => query = value);
            },
            onSubmitted: (String value) {
              setState(() => query = value);
            },
          ),
        ),
        Container(
          color: Colors.grey[200],
          child: FutureBuilder(
            future: DatabaseHelper.getAscents(query),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final data = snapshot.data as List<Ascent>;
              int len = data.length;
              return CupertinoListTile(
                  title: Text(
                    "Ascents: $len",
                    style: Theme.of(context).textTheme.bodySmall,
                    softWrap: false,
                  ),
                  trailing: FutureBuilder(
                      future: DatabaseHelper.getScore(),
                      builder: (context, snapshot) {
                        var score = snapshot.data != null ? snapshot.data : "0";
                        return Text(
                          "Score: $score",
                          style: Theme.of(context).textTheme.bodySmall,
                          softWrap: false,
                        );
                      }));
            },
          ),
        ),
        Flexible(
          child: createScrollView(context, DatabaseHelper.getAscents(query), _buildRow),
        )
      ],
    );
  }

  Widget _buildRow(Ascent ascent) {
    return Card(
      child: CupertinoListTile(
        title: Text(
          "${formatter.format(ascent.date!)}    ${ascent.route!.grade}    ${ascent.style!.name}    ${ascent.route!.name}    ${ascent.score}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                Text(
                  "${ascent.route!.crag!.name}    ${ascent.route!.sector}    stars: ${ascent.stars}",
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            Container(
              child: Text(
                ascent.comment!,
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
      CupertinoPageRoute(builder: (context) => CupertinoAddAscentScreen(passedAscent: ascent)),
    );
    setState(() {});
  }

  void deleteAscent(Ascent ascent) {
    DatabaseHelper.deleteAscent(ascent);
    setState(() {});
  }

  overview() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => OverviewScreen()),
    );
    setState(() {});
  }

  List<BottomNavigationBarItem> buildTabBar(BuildContext context) {
    return [
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.map), label: "Crags"),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.sum), label: "Summary"),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar), label: "Statistics"),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.floppy_disk), label: "Import/Export"),
    ];
  }
}
