import 'package:flutter/material.dart';

import 'model/crag.dart';
import 'database.dart';

class AddCragScreen extends StatelessWidget {
  final Crag? passedCrag;

  AddCragScreen({this.passedCrag}) {
    if (passedCrag != null) {
      nameController.text = passedCrag!.name!;
      countryController.text = passedCrag!.country!;
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Crag"),
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
                    'Crag Name',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Flexible(
                  child: TextField(
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
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Flexible(
                  child: TextField(controller: countryController),
                ),
              ],
            ),
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
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a crag name')),
                      );
                      return;
                    }
                    if (passedCrag != null) {
                      passedCrag!.name = nameController.text;
                      passedCrag!.country = countryController.text;
                      DatabaseHelper.updateCrag(passedCrag!);
                    } else {
                      Crag crag = Crag(name: nameController.text, country: countryController.text);
                      DatabaseHelper.addCrag(crag);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(passedCrag != null ? 'Update' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
