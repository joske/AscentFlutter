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
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    var text = Text(
      crag.name!,
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
    if (Platform.isIOS) {
      return Card(
        color: isDark ? Colors.grey[850] : null,
        child: CupertinoListTile(
          title: text,
          trailing: const CupertinoListTileChevron(),
          onTap: () async {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Text('Edit Crag'),
                    previousPageTitle: 'Crags',
                  ),
                  child: SafeArea(
                    child: CupertinoAddCragScreen(passedCrag: crag),
                  ),
                ),
              ),
            );
            setState(() {});
          },
        ),
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
