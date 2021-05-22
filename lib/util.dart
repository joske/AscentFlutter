import 'package:flutter/material.dart';

Widget buildMainContent<T>(BuildContext context, AsyncSnapshot<List<T>> snapshot, Widget Function(T) buildRow) {
  return Container(
      child: ListView.builder(
    shrinkWrap: true,
    padding: const EdgeInsets.all(10.0),
    itemCount: snapshot.data?.length,
    itemBuilder: (context, i) {
      return buildRow(snapshot.data[i]);
    },
  ));
}
