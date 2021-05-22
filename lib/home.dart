import 'package:ascent/import.dart';
import 'package:ascent/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'add_ascent_screen.dart';
import 'ascent.dart';
import 'cragscreen.dart';
import 'database.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var formatter = new DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: buildDrawer(context),
      ),
      body: createScrollView(context, DatabaseHelper.getAscents(), _buildRow),
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
        // ListTile(
        //   title: Text('Graph'),
        //   onTap: () {
        //     // Update the state of the app.
        //     // ...
        //   },
        // ),
        // ListTile(
        //   title: Text('Pyramid'),
        //   onTap: () {
        //     // Update the state of the app.
        //     // ...
        //   },
        // ),
        // ListTile(
        //   title: Text('Top 10'),
        //   onTap: () {
        //     // Update the state of the app.
        //     // ...
        //   },
        // ),
        ListTile(
          title: Text('Import'),
          onTap: () async {
            Navigator.of(context).pop();
            await importData();
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildRow(Ascent ascent) {
    return Card(
      child: ListTile(
        title: Text(
          "${formatter.format(ascent.date)}    ${ascent.style.name}    ${ascent.route.name}    ${ascent.route.grade}",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                Text(
                  "${ascent.route.crag.name}    ${ascent.route.sector}",
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
    var ascents = await CsvImporter().readFile();
    if (ascents.isNotEmpty) {
      try {
        await DatabaseHelper.clear();
        setState(() {});
        // for (final a in ascents) {
        //   await DatabaseHelper.addAscent(a);
        // }
      } catch (e) {
        print("failed to import $e");
      }
    }
    Navigator.pop(context);
  }
}
