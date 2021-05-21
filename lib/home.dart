import 'dart:io';

import 'package:ascent/cragscreen.dart';
import 'package:ascent/import.dart';
import 'package:ascent/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'add_ascent_screen.dart';
import 'ascent.dart';
import 'database.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  var _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ascents'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Crags')
  ];

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title),
          trailing: CupertinoButton(
            child: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAscentScreen()),
              );
              setState(() {});
            },
          ),
        ),
        child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              items: _items,
            ),
            tabBuilder: (BuildContext context, index) {
              return handleTab(index);
            }),
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: handleTab(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => handleTab(index),
        currentIndex: _currentIndex,
        items: _items,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAscentScreen()),
          );
          setState(() {});
        },
      ),
    );
  }

  handleTab(int index) {
    _currentIndex = index;
    switch (index) {
      case 0:
        return HomeScreen();
        break;
      case 1:
        return CragScreen();
        break;
      default:
        return HomeScreen();
    }
  }

  Future<void> importData() async {
    var dialog = showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Row(
              children: [CircularProgressIndicator(), Text("Importing")],
            ),
          );
        });
    Navigator.pop(context); //pop dialog
    var ascents = await CsvImporter().readFile();
    if (ascents.isNotEmpty) {
      await DatabaseHelper.clear();
      setState(() {});
      for (final a in ascents) {
        await DatabaseHelper.addAscent(a);
      }
    }
  }
}

class HomeScreen extends StatelessWidget {
  final formatter = new DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ascent>>(
      future: DatabaseHelper.getAscents(),
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center();

        return Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: snapshot.data?.length,
            itemBuilder: (context, i) {
              return _buildAscentRow(context, snapshot.data[i]);
            },
          ),
          thickness: 20,
        );
      },
    );
  }

  Widget _buildAscentRow(BuildContext context, Ascent ascent) {
    return PlatformListTile(
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
    );
  }
}
