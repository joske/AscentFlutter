import 'package:ascent/eight_a_import.dart';
import 'package:ascent/import.dart';
import 'package:ascent/pyramid.dart';
import 'package:ascent/statistics.dart';
import 'package:ascent/top10.dart';
import 'package:ascent/widgets/adaptive/adaptive.dart';
import 'package:ascent/widgets/ascent_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_ascent_screen-ios.dart';
import 'add_crag-ios.dart';
import 'cragscreen.dart';
import 'util.dart';
import 'model/ascent.dart';
import 'database.dart';
import 'overview.dart';

class CupertinoHome extends StatefulWidget {
  CupertinoHome({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  CupertinoHomeState createState() => CupertinoHomeState();
}

class CupertinoHomeState extends State<CupertinoHome> {
  String? query;
  TextEditingController? _textController;
  late CupertinoTabController _tabController;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (index) => GlobalKey<NavigatorState>(),
  );

  CupertinoHomeState() {
    _textController = TextEditingController();
    _tabController = CupertinoTabController();
  }

  void switchToHome() {
    _tabController.index = 0;
  }

  void onSubmitted(String value) {
    setState(() => query = value);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        controller: _tabController,
        tabBar: CupertinoTabBar(
          items: buildTabBar(context),
          onTap: (index) {
            // Pop to root if tapping the already selected tab
            if (_tabController.index == index) {
              _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
            }
          },
        ),
        tabBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return buildHomeScreen(index);
            case 1:
              return buildCragScreen(index);
            case 2:
              return buildSummaryScreen(index);
            case 3:
              return buildStatsScreen(index);
            case 4:
              return buildMoreScreen(index);
            default:
              return buildHomeScreen(index);
          }
        });
  }

  Widget buildStatsScreen(int index) {
    return CupertinoTabView(
      navigatorKey: _navigatorKeys[index],
      builder: (BuildContext context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Statistics'),
          ),
          child: StatisticsScreen(),
        );
      },
    );
  }

  Widget buildSummaryScreen(int index) {
    return CupertinoTabView(
      navigatorKey: _navigatorKeys[index],
      builder: (BuildContext context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Summary'),
          ),
          child: OverviewScreen(),
        );
      },
    );
  }

  Widget buildMoreScreen(int index) {
    return CupertinoTabView(
      navigatorKey: _navigatorKeys[index],
      builder: (BuildContext context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('More'),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              CupertinoListSection.insetGrouped(
                header: Text('STATISTICS'),
                children: [
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.star_fill, color: Colors.amber[600], size: 20),
                    title: Text('Top 10'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => Top10Screen()),
                    ),
                  ),
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.chart_bar_alt_fill, color: Colors.orange[600], size: 20),
                    title: Text('Grade Pyramid'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => PyramidScreen()),
                    ),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: Text('DATA'),
                children: [
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.cloud_download, color: Colors.blue[600], size: 20),
                    title: Text('Sync with 8a.nu'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => EightAImportScreen(onComplete: switchToHome)),
                      );
                    },
                  ),
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.arrow_down_doc, color: Colors.green[600], size: 20),
                    title: Text('Import CSV'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => _importData(context),
                  ),
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.arrow_up_doc, color: Colors.indigo[600], size: 20),
                    title: Text('Export CSV'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => _exportData(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
    );
  }

  Future<void> _importData(BuildContext context) async {
    showProgressDialog(context, "Importing");
    try {
      var ascents = (await CsvImporter().readFile())!;
      if (ascents.isNotEmpty) {
        await DatabaseHelper.clear();
        for (final a in ascents) {
          await DatabaseHelper.addAscent(a);
        }
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      showAlertDialog(context, "Error", "Failed to import data");
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
    switchToHome();
  }

  Future<void> _exportData(BuildContext context) async {
    showProgressDialog(context, "Exporting");
    try {
      var ascents = await DatabaseHelper.getAscents(null);
      await CsvImporter().writeFile(ascents);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      showAlertDialog(context, "Error", "Failed to export data");
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
  }

  Widget buildCragScreen(int index) {
    return CupertinoTabView(
      navigatorKey: _navigatorKeys[index],
      builder: (BuildContext context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Crags'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => CupertinoPageScaffold(
                      navigationBar: CupertinoNavigationBar(
                        middle: Text('Add Crag'),
                        previousPageTitle: 'Crags',
                      ),
                      child: SafeArea(
                        child: CupertinoAddCragScreen(),
                      ),
                    ),
                  ),
                );
                setState(() {});
              },
            ),
          ),
          child: CragScreen(),
        );
      },
    );
  }

  Widget buildHomeScreen(int index) {
    return CupertinoTabView(
      navigatorKey: _navigatorKeys[index],
      builder: (BuildContext context) {
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
      },
    );
  }

  Widget buildBody(BuildContext context) {
    final isDark = PlatformUtils.isDarkMode(context);

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
          color: isDark ? Colors.grey[850] : Colors.grey[200],
          child: FutureBuilder(
            future: DatabaseHelper.getAscents(query),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final data = snapshot.data ?? [];
              int len = data.length;
              return CupertinoListTile(
                  title: Text(
                    "Ascents: $len",
                    softWrap: false,
                  ),
                  trailing: FutureBuilder(
                      future: DatabaseHelper.getScore(),
                      builder: (context, snapshot) {
                        var score = snapshot.data != null ? snapshot.data : "0";
                        return Text(
                          "Score: $score",
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
    return AscentCard(
      ascent: ascent,
      trailing: createPopup(ascent, ['edit', 'delete'], [editAscent, deleteAscent]),
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
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar), label: "Stats"),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.ellipsis), label: "More"),
    ];
  }
}
