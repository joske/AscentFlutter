import 'package:ascent/database.dart';
import 'package:flutter/material.dart';

import 'ascent.dart';
import 'crag.dart';
import 'route.dart' as mine;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascents',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Ascents'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AscentDatabase db = AscentDatabase();
  void addAscent() async {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddAscentScreen()),
      );
    });
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
                  MaterialPageRoute(builder: (context) => AddCragScreen()),
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
        future: db.getAscents(),
        initialData: List.empty(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();

          return new ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: snapshot.data?.length,
            itemBuilder: (context, i) {
              return _buildRow(snapshot.data![i]);
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
    );
  }
}

class AddCragScreen extends StatelessWidget {
  final AscentDatabase db = AscentDatabase();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController countryController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Crag"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: Text(
                    'Crag Name',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    controller: nameController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'Country',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Flexible(
                  child: TextField(controller: countryController),
                ),
              ],
            ),
            // buttons below
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Crag crag = new Crag(name: nameController.text, country: countryController.text);
                    db.addCrag(crag);
                    Navigator.pop(context);
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddAscentScreen extends StatelessWidget {
  final AscentDatabase db = AscentDatabase();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController cragController = new TextEditingController();
  final TextEditingController sectorController = new TextEditingController();
  final TextEditingController gradeController = new TextEditingController();
  final TextEditingController commentController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Ascent"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: Text(
                    'Name',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    controller: nameController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'Crag',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: cragController,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: Text(
                    'Sector',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: sectorController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text('Grade'),
                ),
                Flexible(
                  child: TextField(
                    controller: gradeController,
                  ),
                ),
              ],
            ),
            Row(children: [
              SizedBox(
                width: 100,
                child: Text('Comment'),
              ),
            ]),
            Row(children: [
              Flexible(
                child: TextField(
                  controller: commentController,
                ),
              ),
            ]),
            // buttons below
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Crag crag = new Crag(name: cragController.text, country: "Belgium");
                    mine.Route route = new mine.Route(
                      name: nameController.text,
                      crag: crag,
                      sector: sectorController.text,
                      grade: gradeController.text,
                      gradeScore: 1000,
                    );
                    Ascent ascent =
                        new Ascent(route: route, comment: commentController.text, date: DateTime.now(), attempts: 1, stars: 3, score: 1000);
                    db.addAscent(ascent);
                    Navigator.pop(context);
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
