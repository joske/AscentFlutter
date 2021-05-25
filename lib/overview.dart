import 'package:ascent/util.dart';
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
            child: DataTable(
              showCheckboxColumn: false,
              columns: const [DataColumn(label: Text("Grade")), DataColumn(label: Text("Done")), DataColumn(label: Text("Tried"))],
              rows: <DataRow>[
                for (int i = 0; i < snapshot.data.length; i++) buildRow(snapshot.data[i]),
              ],
            ));
      },
    );
  }

  DataRow buildRow(Stats e) {
    return DataRow(
        cells: [DataCell(Text(e.grade)), DataCell(Text(e.done.toString())), DataCell(Text(e.tried.toString()))],
        onSelectChanged: (value) => showDetail(e.grade));
  }

  showDetail(String grade) async {
    showMaterialDialog(context, null, await buildDetailDialog(grade));
  }

  Future<Widget> buildDetailDialog(String grade) async {
    return createScrollView(context, DatabaseHelper.getAscentsWhere("route_grade = ?", [grade]), buildDetailRow);
  }

  Widget buildDetailRow(Ascent ascent) {
    return ListTile(
      title: new Text("${formatter.format(ascent.date)}    ${ascent.route.grade}    ${ascent.style.name}    ${ascent.route.name}"),
      subtitle: Column(
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
      ),
    );
  }
}
