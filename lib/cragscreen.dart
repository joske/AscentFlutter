import 'package:ascent/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Crags'),
      ),
      body: FutureBuilder<List<Crag>>(
        future: DatabaseHelper.getCrags(),
        initialData: List.empty(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center();

          return Scrollbar(
            child: buildMainContent(context, snapshot, _buildRow),
            thickness: 30,
            interactive: true,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCragScreen()),
          );
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildRow(Crag crag) {
    return Card(
        child: ListTile(
      title: new Text(
        crag.name,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    ));
  }
}
