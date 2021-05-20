import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
          ],
        ),
      ),
      body: FutureBuilder<List<Ascent>>(
        future: DatabaseHelper.getAscents(),
        initialData: List.empty(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();

          return new ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: snapshot.data?.length,
            itemBuilder: (context, i) {
              return _buildRow(snapshot.data[i]);
            },
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
    return new ListTile(
      title: new Text(ascent.route.name),
      subtitle: Column(
        children: [
          Text(ascent.route.name),
          Text(ascent.route.grade),
          Text(ascent.comment),
        ],
      ),
    );
  }
}
