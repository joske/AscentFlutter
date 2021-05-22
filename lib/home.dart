import 'package:ascent/import.dart';
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
      body: FutureBuilder<List<Ascent>>(
        future: DatabaseHelper.getAscents(),
        initialData: List.empty(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();

          return Scrollbar(
            child: buildMainContent(context, snapshot),
            thickness: 30,
            interactive: true,
          );
        },
      ),
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

  Widget buildMainContent(BuildContext context, AsyncSnapshot<List<Ascent>> snapshot) {
    return Container(
        child: ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      itemCount: snapshot.data?.length,
      itemBuilder: (context, i) {
        return _buildRow(snapshot.data[i]);
      },
    ));
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
    ));
  }

  static showProgressDialog(BuildContext context, String title) {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              content: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                  ),
                  Flexible(
                      flex: 8,
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> importData() async {
    showProgressDialog(context, "Importing");
    var ascents = await CsvImporter().readFile();
    if (ascents.isNotEmpty) {
      await DatabaseHelper.clear();
      setState(() {});
      for (final a in ascents) {
        await DatabaseHelper.addAscent(a);
      }
    }
    Navigator.pop(context);
  }
}
