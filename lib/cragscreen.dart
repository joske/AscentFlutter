import 'package:flutter/material.dart';

import 'add_crag.dart';
import 'crag.dart';
import 'database.dart';

class CragScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crags'),
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
      body: FutureBuilder<List<Crag>>(
        future: DatabaseHelper.getCrags(),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCragScreen()),
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildRow(Crag crag) {
    return new ListTile(
      title: new Text(crag.name),
    );
  }
}
