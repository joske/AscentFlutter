
import 'package:ascent/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'database.dart';
import "import.dart";

class ImportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 100.0, left: 20, right: 20),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: CupertinoButton(
                  onPressed: () {
                    importData(context);
                  },
                  child: Text("Import"),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: CupertinoButton(
                  onPressed: () {
                    exportData(context);
                  },
                  child: Text("Export"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> importData(BuildContext context) async {
    showProgressDialog(context, "Importing");
    try {
      var ascents = (await CsvImporter().readFile())!;
      if (ascents.isNotEmpty) {
        await DatabaseHelper.clear();
        for (final a in ascents) {
          await DatabaseHelper.addAscent(a);
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Exported ${ascents.length} ascents"),
        ));
      }
    } catch (e) {
      print("failed to import $e");
      Navigator.of(context, rootNavigator: true).pop();
      showAlertDialog(context, "Error", "Failed to Import data");
    }
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> exportData(BuildContext context) async {
    showProgressDialog(context, "Exporting");
    try {
      var ascents = await DatabaseHelper.getAscents(null);
      CsvImporter().writeFile(ascents);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Exported ${ascents.length} ascents"),
      ));
    } catch (e) {
      print("failed to import $e");
      Navigator.of(context, rootNavigator: true).pop();
      showAlertDialog(context, "Error", "Failed to Import data");
    }
    Navigator.of(context, rootNavigator: true).pop();
  }
}
