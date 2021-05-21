import 'package:ascent/widgets.dart';
import 'package:flutter/material.dart';

import 'crag.dart';
import 'database.dart';
import 'widgets.dart';

class AddCragScreen extends StatelessWidget {
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController countryController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      title: "Add Crag",
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: Text(
                    'Crag Name',
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
                  child: Text(
                    'Country',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Flexible(
                  child: PlatformTextField(controller: countryController),
                ),
              ],
            ),
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
                    Crag crag = new Crag(name: nameController.text, country: countryController.text);
                    await DatabaseHelper.addCrag(crag);
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
}
