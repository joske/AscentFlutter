import 'package:flutter/material.dart';

import 'database.dart';
import 'stats.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int year = -1;
  int cragId = -1;

  @override
  Widget build(BuildContext context) {
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
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [DataColumn(label: Text("Grade")), DataColumn(label: Text("Done")), DataColumn(label: Text("Tried"))],
              rows: <DataRow>[
                for (int i = 0; i < snapshot.data.length; i++) buildRow(snapshot.data[i]),
              ],
            ));
      },
    );
  }

  DataRow buildRow(Stats e) {
    return DataRow(cells: [DataCell(Text(e.grade)), DataCell(Text(e.done.toString())), DataCell(Text(e.tried.toString()))]);
  }
}
