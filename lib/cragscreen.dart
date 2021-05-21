import 'package:ascent/widgets.dart';
import 'package:flutter/material.dart';

import 'add_crag.dart';
import 'crag.dart';
import 'database.dart';

class CragScreen extends StatefulWidget {
  @override
  _CragScreenState createState() => _CragScreenState();
}

class _CragScreenState extends State<CragScreen> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      title: 'Crags',
      child: crags(),
      fabOnPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCragScreen()),
        );
        setState(() {});
      },
      fabTooltip: 'Increment',
      fabChild: Icon(Icons.add),
    );
  }

  FutureBuilder<List<Crag>> crags() {
    return FutureBuilder<List<Crag>>(
      future: DatabaseHelper.getCrags(),
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center();

        return new ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(10.0),
          itemCount: snapshot.data?.length,
          itemBuilder: (context, i) {
            return _buildRow(snapshot.data[i]);
          },
        );
      },
    );
  }

  Widget _buildRow(Crag crag) {
    return new PlatformListTile(
      title: new Text(crag.name),
    );
  }
}
