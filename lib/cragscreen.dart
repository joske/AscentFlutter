import 'dart:io';

import 'package:ascent/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_crag-ios.dart';
import 'add_crag.dart';
import 'model/crag.dart';
import 'database.dart';

class CragScreen extends StatefulWidget {
  @override
  _CragScreenState createState() => _CragScreenState();
}

class _CragScreenState extends State<CragScreen> {
  @override
  Widget build(BuildContext context) {
    var body = createScrollView(context, DatabaseHelper.getCrags(), _buildRow);
    if (Platform.isIOS) {
      return Container(padding: EdgeInsets.only(top: 100.0, bottom: 70), child: body);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Crags'),
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCragScreen()),
          );
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildRow(Crag crag) {
    var text = new Text(
      crag.name!,
      style: Theme.of(context).textTheme.bodyLarge,
    );
    if (Platform.isIOS) {
      return Card(
        child: CupertinoListTile(
            title: text, onTap: () => showMaterialDialog(context, "Update Crag", CupertinoAddCragScreen(passedCrag: crag), [], 200, 400)),
      );
    }
    return Card(
        child: ListTile(
            enabled: true,
            title: text,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddCragScreen(
                          passedCrag: crag,
                        )))));
  }
}
