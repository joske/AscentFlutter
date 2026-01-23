import 'package:ascent/util.dart';
import 'package:ascent/widgets/adaptive/adaptive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_crag-ios.dart';
import 'add_crag.dart';
import 'model/crag.dart';
import 'database.dart';

class CragScreen extends StatefulWidget {
  @override
  _CragScreenState createState() => _CragScreenState();
}

class _CragScreenState extends State<CragScreen> {
  @override
  Widget build(BuildContext context) {
    var body = createScrollView(context, DatabaseHelper.getCrags(), _buildRow);
    // On iOS, embedded in CupertinoTabView which handles the nav bar
    if (PlatformUtils.isIOS) {
      return Container(padding: EdgeInsets.only(top: 100.0, bottom: 70), child: body);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Crags'),
      ),
      body: body,
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
    var text = Text(
      crag.name!,
      style: TextStyle(
        fontSize: 16,
        color: PlatformUtils.textColor(context),
      ),
    );

    return AdaptiveListTile(
      title: text,
      showChevron: true,
      onTap: () async {
        if (PlatformUtils.isIOS) {
          await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AdaptiveScaffold(
                title: 'Edit Crag',
                previousPageTitle: 'Crags',
                body: CupertinoAddCragScreen(passedCrag: crag),
              ),
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCragScreen(passedCrag: crag)),
          );
        }
        setState(() {});
      },
    );
  }
}
