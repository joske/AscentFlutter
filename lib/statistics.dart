import 'package:ascent/widgets/adaptive/adaptive.dart';
import 'package:ascent/widgets/ascent_card.dart';
import 'package:flutter/material.dart';

import 'model/ascent.dart';
import 'database.dart';
import 'util.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? year = "All";
  int? cragId = 0;
  int numAscents = 0;

  @override
  Widget build(BuildContext context) {
    // Statistics is embedded in a tab on iOS, needs AdaptiveTabBody
    if (PlatformUtils.isIOS) {
      return AdaptiveTabBody(
        needsMaterial: true,
        child: buildBody(context),
      );
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
                  return DropdownButton(
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
                  return DropdownButton(
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
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "Showing $numAscents Ascents",
            style: TextStyle(color: PlatformUtils.textColor(context)),
          ),
        ),
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
        return Scrollbar(
            thickness: 30,
            interactive: true,
            child: Center(
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, i) {
                      return _buildRow(snapshot.data![i]);
                    })));
      },
    );
  }

  Widget _buildRow(Ascent ascent) {
    return AscentCard(
      ascent: ascent,
      trailing: createPopup(ascent, ['view'], [(a) {}]),
    );
  }

  List<DropdownMenuItem<int>> buildCragList(AsyncSnapshot<List> snapshot) {
    List<DropdownMenuItem<int>> list = snapshot.data!.map((crag) {
      return DropdownMenuItem<int>(
        child: Text(crag.name),
        value: crag.id,
      );
    }).toList();
    list.insert(0, DropdownMenuItem<int>(child: Text("All"), value: 0));
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
