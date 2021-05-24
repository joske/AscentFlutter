import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'ascent.dart';
import 'crag.dart';
import 'database.dart';
import 'route.dart' as mine;
import 'style.dart';

class AddAscentScreen extends StatefulWidget {
  final Ascent passedAscent;

  AddAscentScreen({Key key, this.passedAscent});

  @override
  _AddAscentScreenState createState() => _AddAscentScreenState(passedAscent: passedAscent);
}

class _AddAscentScreenState extends State<AddAscentScreen> {
  final Ascent passedAscent;

  final TextEditingController nameController = new TextEditingController();
  final TextEditingController sectorController = new TextEditingController();
  final TextEditingController commentController = new TextEditingController();
  DateTime currentDate = DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  var styleId = 1;
  var grade = "6a";
  var cragId;
  var stars = 0.0;

  _AddAscentScreenState({this.passedAscent}) {
    if (passedAscent != null) {
      styleId = passedAscent.style.id;
      grade = passedAscent.route.grade;
      cragId = passedAscent.route.crag.id;
      nameController.text = passedAscent.route.name;
      sectorController.text = passedAscent.route.sector;
      currentDate = passedAscent.date;
      commentController.text = passedAscent.comment;
      stars = passedAscent != null && passedAscent.stars != null ? passedAscent.stars.toDouble() : 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: passedAscent != null ? Text("Edit Ascent") : Text("Add Ascent"),
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
                  child: TextField(
                    textCapitalization: TextCapitalization.words,
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
                SizedBox(
                  width: 200,
                  height: 50,
                  child: FutureBuilder<List>(
                    future: DatabaseHelper.getCrags(),
                    initialData: List.empty(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center();
                      return new DropdownButton(
                          value: cragId,
                          hint: Text("Select Crag"),
                          items: buildCragList(snapshot),
                          onChanged: (value) {
                            setState(() {
                              cragId = value;
                            });
                          });
                    },
                  ),
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
                    textCapitalization: TextCapitalization.words,
                    controller: sectorController,
                  ),
                ),
              ],
            ),
            Row(children: [
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
            ]),
            Row(
              children: [
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
                  textCapitalization: TextCapitalization.sentences,
                  controller: commentController,
                ),
              ),
            ]),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SmoothStarRating(
                  allowHalfRating: false,
                  starCount: 3,
                  size: 30.0,
                  rating: stars,
                  onRated: (double value) {
                    setState(() {
                      stars = value;
                    });
                  },
                ),
              ],
            ),
            // buttons below
            SizedBox(
              height: 10,
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
                  onPressed: () async {
                    Crag crag = new Crag(id: cragId);
                    mine.Route route = new mine.Route(
                      name: nameController.text,
                      crag: crag,
                      sector: sectorController.text,
                      grade: grade,
                    );
                    Ascent ascent = new Ascent(
                        route: route,
                        comment: commentController.text,
                        date: currentDate,
                        attempts: 1,
                        stars: stars.toInt(),
                        style: Style(id: styleId));
                    if (passedAscent != null) {
                      ascent.id = passedAscent.id;
                      ascent.route.id = passedAscent.route.id;
                      ascent.route.crag.id = cragId;
                      await DatabaseHelper.updateAscent(ascent);
                    } else {
                      await DatabaseHelper.addAscent(ascent);
                    }
                    Navigator.pop(context);
                  },
                  child: passedAscent != null ? Text("Update") : Text('Add'),
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
