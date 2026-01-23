import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model/ascent.dart';
import 'database.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? year = "All";
  int? cragId = 0;
  int numAscents = 0;
  DateFormat formatter = new DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Material(
          child: Container(
        padding: EdgeInsets.only(top: 95.0),
        child: buildBody(context),
      ));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Statistics'),
        ),
        body: buildBody(context));
  }

  Widget buildBody(BuildContext context) {
    return Column(children: [
      Row(children: [
        Flexible(
            child: ListTile(
          leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            FutureBuilder<List>(
                future: DatabaseHelper.getYearsWithAscents(),
                initialData: List.empty(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  if (year == "All" && snapshot.data!.length > 0) {
                    year = snapshot.data![0];
                  }
                  return new DropdownButton(
                      value: year,
                      hint: Text("Year"),
                      items: buildYears(snapshot),
                      onChanged: (dynamic value) async {
                        var len = (await DatabaseHelper.getAscentsForCrag(value, cragId!)).length;
                        setState(() {
                          year = value;
                          numAscents = len;
                        });
                      });
                }),
          ]),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            FutureBuilder<List>(
                future: DatabaseHelper.getCrags(),
                initialData: List.empty(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return new DropdownButton(
                      value: cragId,
                      hint: Text("Select Crag"),
                      items: buildCragList(snapshot),
                      onChanged: (dynamic value) async {
                        var len = (await DatabaseHelper.getAscentsForCrag(year, value)).length;
                        setState(() {
                          cragId = value;
                          numAscents = len;
                        });
                      });
                }),
          ]),
        ))
      ]),
      Row(children: [
        Text("Showing $numAscents Ascents"),
      ]),
      Flexible(
        child: buildRows(context),
      ),
    ]);
  }

  Widget buildRows(BuildContext context) {
    return FutureBuilder<List<Ascent>>(
      future: DatabaseHelper.getAscentsForCrag(year, cragId!),
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        numAscents = snapshot.data!.length;
        return new Scrollbar(
            thickness: 30,
            interactive: true,
            child: Center(
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, i) {
                      return buildRow(snapshot.data![i]);
                    })));
      },
    );
  }

  Widget buildRow(Ascent ascent) {
    return Card(
      child: ListTile(
        title: Text(
          "${formatter.format(ascent.date!)}    ${ascent.route!.grade}    ${ascent.style!.name}    ${ascent.route!.name}    ${ascent.score}",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                Text(
                  "${ascent.route!.crag!.name}    ${ascent.route!.sector}    stars: ${ascent.stars}",
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
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> buildCragList(AsyncSnapshot<List> snapshot) {
    List<DropdownMenuItem<int>> list = snapshot.data!.map((crag) {
      return DropdownMenuItem<int>(
        child: Text(crag.name),
        value: crag.id,
      );
    }).toList();
    list.insert(0, new DropdownMenuItem<int>(child: Text("All"), value: 0));
    return list;
  }

  List<DropdownMenuItem<String>> buildYears(AsyncSnapshot<List> snapshot) {
    List<DropdownMenuItem<String>> list = snapshot.data!.map((year) {
      return DropdownMenuItem<String>(
        child: Text(year),
        value: year,
      );
    }).toList();
    return list;
  }
}
