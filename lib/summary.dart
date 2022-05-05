// @dart=2.9
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ascent.dart';
import 'database.dart';

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
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
          title: Text('Summary'),
        ),
        body: Column(children: [
          Row(children: [
            Flexible(
                child: ListTile(
              leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                FutureBuilder<List>(
                    future: DatabaseHelper.getFirstYearWithAscents(),
                    initialData: List.empty(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center();
                      if (year == -1 && snapshot.data.length > 0) {
                        year = snapshot.data[0];
                      }
                      return new DropdownButton(
                          value: year,
                          hint: Text("Year"),
                          items: buildYears(snapshot),
                          onChanged: (value) {
                            setState(() {
                              year = value;
                            });
                          });
                    }),
              ]),
              trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                FutureBuilder<List>(
                    future: DatabaseHelper.getCrags(),
                    initialData: List.empty(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center();
                      if (cragId == -1) {
                        cragId = 1; // if we get here we have at least 1 item
                      }
                      return new DropdownButton(
                          value: cragId,
                          hint: Text("Select Crag"),
                          items: buildCragList(snapshot),
                          onChanged: (value) {
                            setState(() {
                              cragId = value;
                            });
                          });
                    }),
              ]),
            ))
          ]),
          Flexible(
            child: buildRows(context),
          ),
        ]));
  }

  Widget buildRows(BuildContext context) {
    return FutureBuilder<List<Ascent>>(
      future: DatabaseHelper.getAscentsForCrag(year, cragId),
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center();
        if (cragId == -1) {
          cragId = 1; // if we get here, we have at least 1 crag
        }
        return new Scrollbar(
            thickness: 30,
            interactive: true,
            child: Center(
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, i) {
                      return buildRow(snapshot.data[i]);
                    })));
      },
    );
  }

  Widget buildRow(Ascent ascent) {
    return Card(
      child: ListTile(
        title: Text(
          "${formatter.format(ascent.date)}    ${ascent.route.grade}    ${ascent.style.name}    ${ascent.route.name}    ${ascent.score}",
          style: Theme.of(context).textTheme.bodyText1,
        ),
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
      ),
    );
  }

  List<DropdownMenuItem<int>> buildCragList(AsyncSnapshot<List> snapshot) {
    List<DropdownMenuItem<int>> list = snapshot.data.map((crag) {
      return DropdownMenuItem<int>(
        child: Text(crag.name),
        value: crag.id,
      );
    }).toList();
    return list;
  }

  List<DropdownMenuItem<int>> buildYears(AsyncSnapshot<List> snapshot) {
    List<DropdownMenuItem<int>> list = snapshot.data.map((year) {
      return DropdownMenuItem<int>(
        child: Text(year.toString()),
        value: year,
      );
    }).toList();
    return list;
  }
}
