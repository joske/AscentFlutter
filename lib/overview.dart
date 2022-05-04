// @dart=2.9
import 'dart:io';

import 'package:ascent/util.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ascent.dart';
import 'database.dart';
import 'stats.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int year = -1;
  int cragId = -1;
  DateFormat formatter = new DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Material(
          child: Container(
        padding: EdgeInsets.only(top: 30.0),
        child: buildRows(context),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: buildRows(context),
    );
  }

  Widget buildRows(BuildContext context) {
    return FutureBuilder<List<Stats>>(
      future: DatabaseHelper.getStats(year, cragId),
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center();

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
                child: DataTable(
              showCheckboxColumn: false,
              columns: const [DataColumn(label: Text("Grade")), DataColumn(label: Text("Done")), DataColumn(label: Text("Tried"))],
              rows: <DataRow>[
                for (int i = 0; i < snapshot.data.length; i++) buildRow(snapshot.data[i]),
              ],
            )));
      },
    );
  }

  DataRow buildRow(Stats e) {
    return DataRow(
        cells: [DataCell(Text(e.grade)), DataCell(Text(e.done.toString())), DataCell(Text(e.tried.toString()))],
        onSelectChanged: (value) => showDetail(e.grade));
  }

  showDetail(String grade) async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showMaterialDialog(
        context,
        null,
        await buildDetailDialog(grade),
        <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
        height - 100,
        width);
  }

  Future<Widget> buildDetailDialog(String grade) async {
    return createScrollView(context, DatabaseHelper.getAscentsWhere("route_grade = ?", [grade]), buildDetailRow);
  }

  Widget buildDetailRow(Ascent ascent) {
    var title = new Text("${formatter.format(ascent.date)}    ${ascent.route.grade}    ${ascent.style.name}    ${ascent.route.name}");
    var subtitle = Column(
      children: [
        Row(
          children: [
            Text(
              "${ascent.route.crag.name}    ${ascent.route.sector}    stars: ${ascent.stars}",
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
    );
    if (Platform.isIOS) {
      return CupertinoListTile(
        title: title,
        subtitle: subtitle,
      );
    } else {
      return ListTile(
        title: title,
        subtitle: subtitle,
      );
    }
  }
}
