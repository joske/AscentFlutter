import 'dart:io';

import 'package:ascent/ascent.dart';
import 'package:ascent/database.dart';
import 'package:flutter/material.dart';

class Top10Screen extends StatefulWidget {
  @override
  _Top10ScreenState createState() => _Top10ScreenState();
}

class _Top10ScreenState extends State<Top10Screen> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Material(
          child: Container(
        padding: EdgeInsets.only(top: 100.0, bottom: 100),
        child: ListView(
          children: [
            buildHeader(context),
            buildRows(context, DatabaseHelper.getTop10AllTime()),
            buildRows(context, DatabaseHelper.getTop10Last12Months())
          ],
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Top 10'),
      ),
      body: ListView(
        children: [
          buildHeader(context),
          buildRows(context, DatabaseHelper.getTop10AllTime()),
          buildRows(context, DatabaseHelper.getTop10Last12Months())
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return FutureBuilder<List<int>>(
        future: Future.wait([
          DatabaseHelper.getTop10ScoreAllTime(),
          DatabaseHelper.getTop10ScoreLast12Months()
        ]),
        builder: (context, AsyncSnapshot<List<int>> snapshot) {
          if (!snapshot.hasData) return Center();
          int scoreAllTime = snapshot.data![0];
          int scoreLast12 = snapshot.data![1];
          return Row(children: [
            Text("All Time: $scoreAllTime"),
            Spacer(),
            Text("Last 12 Months: $scoreLast12")
          ]);
        });
  }

  Widget buildRows(BuildContext context, Future<List<Ascent>> future) {
    return FutureBuilder<List<Ascent>>(
      future: future,
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center();
        return Row(children: [
          DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text("Score")),
              DataColumn(label: Text("Grade")),
              DataColumn(label: Text("Name")),
            ],
            rows: <DataRow>[
              for (int i = 0; i < snapshot.data!.length; i++)
                buildRow(snapshot.data![i]),
            ],
          )
        ]);
      },
    );
  }

  DataRow buildRow(Ascent e) {
    String crag = e.route!.crag != null && e.route!.crag!.name != null ? e.route!.crag!.name! : "";
    String name = e.route!.name! + "\n" + crag;
    return DataRow(
      cells: [
        DataCell(Text(e.score!.toString())),
        DataCell(Text(e.route!.grade!)),
        DataCell(Text(name)),
      ],
    );
  }
}
