import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model/ascent.dart';
import 'model/crag.dart';
import 'database.dart';
import 'model/route.dart' as mine;
import 'model/style.dart';

class CupertinoAddAscentScreen extends StatefulWidget {
  final Ascent? passedAscent;

  CupertinoAddAscentScreen({Key? key, this.passedAscent});

  @override
  _CupertinoAddAscentScreenState createState() => _CupertinoAddAscentScreenState(passedAscent: passedAscent);
}

class _CupertinoAddAscentScreenState extends State<CupertinoAddAscentScreen> {
  final Ascent? passedAscent;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController sectorController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  DateTime? currentDate = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  int? styleId = 0;
  String? grade = "6a";
  var cragId;
  var stars = 0.0;
  var cragIndex = 0;
  var gradeIndex = 0;
  List<Crag>? crags;
  List<String>? grades;

  _CupertinoAddAscentScreenState({this.passedAscent}) {
    if (passedAscent != null) {
      styleId = passedAscent!.style?.id ?? 0;
      grade = passedAscent!.route?.grade ?? "6a";
      cragId = passedAscent!.route?.crag?.id;
      nameController.text = passedAscent!.route?.name ?? '';
      sectorController.text = passedAscent!.route?.sector ?? '';
      currentDate = passedAscent!.date ?? DateTime.now();
      commentController.text = passedAscent!.comment ?? '';
      stars = passedAscent!.stars?.toDouble() ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    var title = passedAscent != null ? "Edit Ascent" : "Add Ascent";

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      resizeToAvoidBottomInset: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 100.0, left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(width: 100, child: Text('Name', style: Theme.of(context).textTheme.bodyLarge)),
                Flexible(
                  child: CupertinoTextField(textCapitalization: TextCapitalization.words, controller: nameController),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 100, child: Text('Crag', style: Theme.of(context).textTheme.bodyLarge)),
                SizedBox(
                  width: 200,
                  height: 100,
                  child: FutureBuilder<List<Crag>>(
                    future: DatabaseHelper.getCrags(),
                    initialData: List.empty(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null || snapshot.data!.length == 0) return CircularProgressIndicator();
                      crags = snapshot.data;
                      if (passedAscent != null) {
                        Crag c = crags!.firstWhere((element) => element.id == cragId);
                        cragIndex = crags!.indexOf(c);
                      }
                      return CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: cragIndex),
                        looping: false,
                        itemExtent: 32,
                        children: buildCragListIOS(snapshot),
                        onSelectedItemChanged: (value) {
                          setState(() {
                            cragIndex = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: 100, child: Text('Sector', style: Theme.of(context).textTheme.bodyLarge)),
                Flexible(
                  child: CupertinoTextField(textCapitalization: TextCapitalization.words, controller: sectorController),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 100, child: Text('Grade', style: Theme.of(context).textTheme.bodyLarge)),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: FutureBuilder<List<String>>(
                    future: DatabaseHelper.getGrades(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      grades = snapshot.data;
                      var fixedExtentScrollController;
                      String c = grades!.firstWhere((element) => element == grade);
                      gradeIndex = grades!.indexOf(c);
                      fixedExtentScrollController = FixedExtentScrollController(initialItem: gradeIndex);
                      return CupertinoPicker(
                        scrollController: fixedExtentScrollController,
                        looping: false,
                        itemExtent: 32,
                        children: buildGradeListIOS(snapshot),
                        onSelectedItemChanged: (value) {
                          setState(() {
                            gradeIndex = value;
                            grade = grades![gradeIndex];
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 100, child: Text('Style', style: Theme.of(context).textTheme.bodyLarge)),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: styleId! - 1),
                    looping: false,
                    itemExtent: 32,
                    children: buildStyleListIOS(DatabaseHelper.styles),
                    onSelectedItemChanged: (value) {
                      setState(() {
                        styleId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 100, child: Text('Date', style: Theme.of(context).textTheme.bodyLarge)),
                SizedBox(width: 100, child: Text(formatter.format(currentDate!))),
                CupertinoButton(
                  onPressed: () {
                    selectDate(context);
                  },
                  child: Text('Pick Date'),
                ),
              ],
            ),
            Row(
              children: [SizedBox(width: 100, child: Text('Comment', style: Theme.of(context).textTheme.bodyLarge))],
            ),
            Row(
              children: [
                Flexible(
                  child: CupertinoTextField(textCapitalization: TextCapitalization.sentences, controller: commentController),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(width: 10),
                CupertinoButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('Validation Error'),
                          content: Text('Please enter a route name'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    if (crags == null || crags!.isEmpty) {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('Validation Error'),
                          content: Text('Please select a crag'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    Crag crag = crags![cragIndex];
                    grade = grades![this.gradeIndex];
                    mine.Route route = mine.Route(name: nameController.text, crag: crag, sector: sectorController.text, grade: grade);
                    Ascent ascent = Ascent(
                      route: route,
                      comment: commentController.text,
                      date: currentDate,
                      attempts: 1,
                      stars: stars.toInt(),
                      style: Style(id: styleId! + 1),
                    );
                    if (passedAscent != null) {
                      ascent.id = passedAscent!.id;
                      ascent.route!.id = passedAscent!.route!.id;
                      ascent.route!.crag!.id = cragId;
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

  Future selectDate(BuildContext context) async {
    DateTime? pickedDate;
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 500,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              height: 400,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (val) {
                  setState(() {
                    pickedDate = val;
                  });
                },
              ),
            ),

            // Close the modal
            CupertinoButton(child: Text('OK'), onPressed: () => Navigator.of(context, rootNavigator: true).pop()),
          ],
        ),
      ),
    );
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
      });
  }

  List<Widget> buildStyleListIOS(List<Style> snapshot) {
    List<Widget> list = snapshot.map((style) {
      return Text(style.name!);
    }).toList();
    return list;
  }

  List<Widget> buildCragListIOS(AsyncSnapshot<List> snapshot) {
    List<Widget> list = snapshot.data!.map((crag) {
      return Text(crag.name);
    }).toList();
    return list;
  }

  List<Widget> buildGradeListIOS(AsyncSnapshot<List> snapshot) {
    List<Widget> list = snapshot.data!.map((value) {
      return Text(value);
    }).toList();
    return list;
  }
}
