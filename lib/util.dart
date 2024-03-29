import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget createScrollView<T>(BuildContext context, Future<List<T>> future, Widget Function(T) buildRow) {
  return FutureBuilder<List<T>>(
    future: future,
    initialData: List.empty(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();

      return Scrollbar(
        child: buildMainContent(context, snapshot, buildRow),
        thickness: 30,
        interactive: true,
      );
    },
  );
}

Widget buildMainContent<T>(BuildContext context, AsyncSnapshot<List<T>> snapshot, Widget Function(T) buildRow) {
  return Container(
      child: ListView.builder(
    shrinkWrap: true,
    padding: const EdgeInsets.all(10.0),
    itemCount: snapshot.data?.length,
    itemBuilder: (context, i) {
      return buildRow(snapshot.data![i]);
    },
  ));
}

Widget createPopup<T>(T item, List<String> menuItems, List<void Function(T)> action) {
  return PopupMenuButton(
    itemBuilder: (context) {
      return menuItems.map((e) => PopupMenuItem(child: Text(e), value: e)).toList();
    },
    onSelected: (String value) {
      var i = menuItems.indexOf(value);
      action[i].call(item);
    },
  );
}

showProgressDialog(BuildContext context, String title) {
  try {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                CircularProgressIndicator(),
                Padding(
                  padding: EdgeInsets.only(left: 15),
                ),
                Flexible(
                    flex: 8,
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          );
        });
  } catch (e) {
    print(e.toString());
  }
}

showAlertDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

showMaterialDialog(BuildContext context, String? title, Widget content, List<Widget> actions, double height, double width) {
  if (Platform.isIOS) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: title != null ? Text(title) : null,
              content: SizedBox(
                child: content,
                height: height,
                width: width,
              ),
              actions: actions,
            ));
  } else {
    showDialog(
        context: context,
        builder: (_) {
          return new AlertDialog(
            title: title != null ? Text(title) : null,
            content: SizedBox(
              child: content,
              height: height,
              width: width,
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
