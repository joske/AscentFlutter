import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ascent.dart';
import 'crag.dart';
import 'database.dart';
import 'route.dart' as mine;
import 'style.dart';

class AddAscentScreen extends StatefulWidget {
  @override
  _AddAscentScreenState createState() => _AddAscentScreenState();
}

class _AddAscentScreenState extends State<AddAscentScreen> {
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController sectorController = new TextEditingController();
  final TextEditingController dateController = new TextEditingController();
  final TextEditingController commentController = new TextEditingController();
  DateTime currentDate = DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  var styleId = 1;
  var grade = "6a";
  var cragId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Ascent"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: Text(
                    'Name',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    controller: nameController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'Crag',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                FutureBuilder<List>(
                  future: DatabaseHelper.getCrags(),
                  initialData: List.empty(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center();
                    return new DropdownButton(
                        value: cragId,
                        items: buildCragList(snapshot),
                        onChanged: (value) {
                          setState(() {
                            cragId = value;
                          });
                        });
                  },
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: Text(
                    'Sector',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: sectorController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'Grade',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                FutureBuilder<List>(
                  future: DatabaseHelper.getGrades(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center();
                    return new DropdownButton(
                        value: grade,
                        items: buildGradeList(snapshot),
                        onChanged: (value) {
                          setState(() {
                            grade = value;
                          });
                        });
                  },
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'Style',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                FutureBuilder<List>(
                  future: DatabaseHelper.getStyles(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center();
                    return new DropdownButton(
                        value: styleId,
                        items: buildStyleList(snapshot),
                        onChanged: (value) {
                          setState(() {
                            styleId = value;
                          });
                        });
                  },
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'Date',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(formatter.format(currentDate)),
                ),
                ElevatedButton(
                    onPressed: () {
                      selectDate(context);
                    },
                    child: Text('Pick Date')),
              ],
            ),
            Row(children: [
              SizedBox(
                width: 100,
                child: Text(
                  'Comment',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ]),
            Row(children: [
              Flexible(
                child: TextField(
                  controller: commentController,
                ),
              ),
            ]),
            // buttons below
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Crag crag = new Crag(id: cragId);
                    mine.Route route = new mine.Route(
                      name: nameController.text,
                      crag: crag,
                      sector: sectorController.text,
                      grade: grade,
                    );
                    Ascent ascent = new Ascent(
                        route: route, comment: commentController.text, date: currentDate, attempts: 1, stars: 3, style: Style(id: styleId));
                    DatabaseHelper.addAscent(ascent);
                    Navigator.pop(context);
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem> buildGradeList(AsyncSnapshot<List> snapshot) {
    List<DropdownMenuItem> list = snapshot.data.map((grade) {
      return DropdownMenuItem<String>(
        child: Text(grade),
        value: grade,
      );
    }).toList();
    return list;
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

  Future selectDate(BuildContext context) async {
    final DateTime pickedDate =
        await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900, 1, 1), lastDate: DateTime.now());
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
      });
  }

  List<DropdownMenuItem> buildStyleList(AsyncSnapshot<List> snapshot) {
    List<DropdownMenuItem> list = snapshot.data.map((style) {
      return DropdownMenuItem<int>(
        child: Text(style.name),
        value: style.id,
      );
    }).toList();
    return list;
  }
}
