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
  void addAscent() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAscentScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
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
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CragScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Graph'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('Pyramid'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('Top 10'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('Import'),
              onTap: () {
                importData();
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Ascent>>(
        future: DatabaseHelper.getAscents(),
        initialData: List.empty(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();

          return Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, i) {
                return _buildRow(snapshot.data[i]);
              },
            ),
            thickness: 20,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addAscent,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
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
          ),
        ],
      ),
    ));
  }

  void importData() async {
    var ascents = await CsvImporter().readFile();
    if (ascents.isNotEmpty) {
      DatabaseHelper.clear();
      for (final a in ascents) {
        await DatabaseHelper.addAscent(a);
      }
      setState(() {});
    }
  }
}
