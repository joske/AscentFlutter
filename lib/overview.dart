import 'dart:io';

import 'package:ascent/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model/ascent.dart';
import 'database.dart';
import 'model/stats.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int year = -1;
  int cragId = -1;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Material(
          child: Container(
        padding: EdgeInsets.only(top: 100.0, bottom: 100),
        child: buildRows(context),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: buildRows(context),
    );
  }

  Widget buildRows(BuildContext context) {
    return FutureBuilder<List<Stats>>(
      future: DatabaseHelper.getStats(year, cragId),
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) CircularProgressIndicator();

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
                child: DataTable(
              showCheckboxColumn: false,
              columns: const [DataColumn(label: Text("Grade")), DataColumn(label: Text("Done")), DataColumn(label: Text("Tried"))],
              rows: <DataRow>[
                for (int i = 0; i < snapshot.data!.length; i++) buildRow(snapshot.data![i]),
              ],
            )));
      },
    );
  }

  DataRow buildRow(Stats e) {
    return DataRow(
        cells: [DataCell(Text(e.grade!)), DataCell(Text(e.done.toString())), DataCell(Text(e.tried.toString()))],
        onSelectChanged: (value) => {
              if (Platform.isIOS)
                {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: true,
                      pageBuilder: (context, _, __) {
                        return FullDialogPage(e.grade!);
                      },
                    ),
                  )
                }
              else
                {showDetail(e.grade)}
            });
  }

  showDetail(String? grade) async {
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

  Future<Widget> buildDetailDialog(String? grade) async {
    return DialogBuilder.buildScrollView(context, grade);
  }
}

class DialogBuilder {
  static DateFormat formatter = new DateFormat('yyyy-MM-dd');

  static Widget buildScrollView(BuildContext context, String? grade) {
    return createScrollView(context, DatabaseHelper.getAscentsWhere("route_grade = ?", [grade]), buildDetailRow);
  }

  static Widget buildDetailRow(Ascent ascent) {
    var title = new Text("${formatter.format(ascent.date!)}    ${ascent.route!.grade}    ${ascent.style!.name}    ${ascent.route!.name}");
    var subtitle = Column(
      children: [
        Row(
          children: [
            Text(
              "${ascent.route!.crag!.name}    ${ascent.route!.sector}",
              textAlign: TextAlign.left,
            ),
          ],
        ),
        Container(
          child: Text(
            ascent.comment!,
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

//Second Page
class FullDialogPage extends StatefulWidget {
  final String grade;
  FullDialogPage(this.grade);

  @override
  _FullDialogPageState createState() => _FullDialogPageState(grade);
}

class _FullDialogPageState extends State<FullDialogPage> with TickerProviderStateMixin {
  late String grade;
  late AnimationController _primary, _secondary;
  late Animation<double> _animationPrimary, _animationSecondary;

  _FullDialogPageState(String grade) {
    this.grade = grade;
  }

  @override
  void initState() {
    //Primaty
    _primary = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationPrimary = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _primary, curve: Curves.easeOut));
    //Secondary
    _secondary = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationSecondary = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _secondary, curve: Curves.easeOut));
    _primary.forward();
    super.initState();
  }

  @override
  void dispose() {
    _primary.dispose();
    _secondary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoFullscreenDialogTransition(
      primaryRouteAnimation: _animationPrimary,
      secondaryRouteAnimation: _animationSecondary,
      linearTransition: false,
      child: Container(
          padding: EdgeInsets.only(top: 100, bottom: 100),
          child: Column(
            children: [
              Flexible(child: DialogBuilder.buildScrollView(context, grade)),
              Row(
                children: [
                  CupertinoButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              )
            ],
          )),
    );
  }
}
