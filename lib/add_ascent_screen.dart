import 'dart:io';

import 'package:ascent/widgets.dart';
import 'package:flutter/cupertino.dart';
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
  var cragIndex;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      title: "Add Ascent",
      child: Container(
        height: 600,
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 200,
                  height: 100,
                  child: Text(
                    'Name',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Flexible(
                  child: PlatformTextField(
                    controller: nameController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Text(
                    'Crag',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                buildCragPicker(),
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
                  child: PlatformTextField(
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
                buildGradePicker(),
                Flexible(
                  child: Text(
                    'Style',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                buildStylePicker(),
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
                  child: Text(formatter.format(currentDate), style: Theme.of(context).textTheme.bodyText1),
                ),
                Flexible(
                  child: PlatformButton(
                      onPressed: () {
                        selectDate(context);
                      },
                      child: Text('Pick Date')),
                ),
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
                child: PlatformTextField(
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
                PlatformButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(
                  width: 10,
                ),
                PlatformButton(
                  onPressed: () async {
                    Crag crag = new Crag(id: cragId);
                    if (cragIndex != null) {
                      List<Crag> crags = await DatabaseHelper.getCrags();
                      crag = crags[cragIndex];
                    }
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

  Widget buildGradePicker() {
    if (Platform.isAndroid) {
      return FutureBuilder<List>(
        future: DatabaseHelper.getGrades(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();
          return new DropdownButton(
              value: grade,
              items: buildGradeListAndroid(snapshot),
              onChanged: (value) {
                setState(() {
                  grade = value;
                });
              });
        },
      );
    } else {
      return FutureBuilder<List>(
        future: DatabaseHelper.getGrades(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();
          return Flexible(
              child: CupertinoPicker(
            magnification: 1.2,
            looping: false,
            itemExtent: 32,
            onSelectedItemChanged: (value) {
              setState(() {
                // grade = value;
              });
            },
            children: buildStringListIOS(snapshot),
          ));
        },
      );
    }
  }

  List<Widget> buildGradeListAndroid(AsyncSnapshot<List> snapshot) {
    List<Widget> list = snapshot.data.map((grade) {
      return DropdownMenuItem(
        child: Text(grade),
        value: grade,
      );
    }).toList();
    return list;
  }

  Widget buildCragPicker() {
    if (Platform.isAndroid) {
      return FutureBuilder<List>(
        future: DatabaseHelper.getCrags(),
        initialData: List.empty(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();
          return new DropdownButton(
              value: cragId,
              items: buildCragListAndroid(snapshot),
              onChanged: (value) {
                setState(() {
                  cragId = value;
                });
              });
        },
      );
    } else if (Platform.isIOS) {
      return SizedBox(
          width: 100,
          height: 100,
          child: FutureBuilder<List>(
            future: DatabaseHelper.getCrags(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center();
              return Flexible(
                  child: CupertinoPicker(
                looping: false,
                itemExtent: 32,
                onSelectedItemChanged: (value) {
                  setState(() {
                    cragIndex = value;
                  });
                },
                children: buildCragListIOS(snapshot),
              ));
            },
          ));
    } else {
      return Center();
    }
  }

  List<Widget> buildCragListAndroid(AsyncSnapshot<List> snapshot) {
    List<Widget> list = snapshot.data.map((crag) {
      return DropdownMenuItem(
        child: Text(crag.name),
        value: crag.id,
      );
    }).toList();
    return list;
  }

  Future selectDate(BuildContext context) async {
    if (Platform.isAndroid) {
      final DateTime pickedDate =
          await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900, 1, 1), lastDate: DateTime.now());
      if (pickedDate != null && pickedDate != currentDate)
        setState(() {
          currentDate = pickedDate;
        });
    } else if (Platform.isIOS) {
      await bottomSheet(context, datetimePicker());
    }
  }

  Future<void> bottomSheet(BuildContext context, Widget child, {double height}) {
    return showModalBottomSheet(
        isScrollControlled: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13))),
        backgroundColor: Colors.white,
        context: context,
        builder: (context) => Container(height: height ?? MediaQuery.of(context).size.height / 3, child: child));
  }

  Widget datetimePicker() {
    return CupertinoDatePicker(
      initialDateTime: DateTime.now(),
      onDateTimeChanged: (DateTime newdate) {
        setState(() {
          currentDate = newdate;
        });
      },
      use24hFormat: true,
      maximumDate: new DateTime(2021, 12, 30),
      minimumYear: 1900,
      mode: CupertinoDatePickerMode.date,
    );
  }

  dynamic buildStylePicker() {
    if (Platform.isAndroid) {
      return FutureBuilder<List>(
        future: DatabaseHelper.getStyles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();
          return new DropdownButton(
              value: styleId,
              items: buildStyleListAndroid(snapshot),
              onChanged: (value) {
                setState(() {
                  styleId = value;
                });
              });
        },
      );
    } else if (Platform.isIOS) {
      return FutureBuilder<List>(
        future: DatabaseHelper.getStyles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();
          return Flexible(
              child: CupertinoPicker(
            looping: false,
            itemExtent: 32,
            onSelectedItemChanged: (value) {
              setState(() {
                styleId = value;
              });
            },
            children: buildStyleListIOS(snapshot),
          ));
        },
      );
    }
  }

  List<Widget> buildStyleListIOS(AsyncSnapshot<List> snapshot) {
    List<Widget> list = snapshot.data.map((style) {
      return Text(style.name);
    }).toList();
    return list;
  }

  List<Widget> buildCragListIOS(AsyncSnapshot<List> snapshot) {
    List<Widget> list = snapshot.data.map((style) {
      return Text(style.name);
    }).toList();
    return list;
  }

  List<Widget> buildStringListIOS(AsyncSnapshot<List> snapshot) {
    List<Widget> list = snapshot.data.map((value) {
      return Text(value);
    }).toList();
    return list;
  }

  List<Widget> buildStyleListAndroid(AsyncSnapshot<List> snapshot) {
    List<Widget> list = snapshot.data.map((style) {
      return DropdownMenuItem(
        child: Text(style.name),
        value: style.id,
      );
    }).toList();
    return list;
  }
}
