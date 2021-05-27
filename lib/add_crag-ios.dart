import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'crag.dart';
import 'database.dart';

class CupertinoAddCragScreen extends StatelessWidget {
  final Crag passedCrag;

  CupertinoAddCragScreen({this.passedCrag}) {
    if (passedCrag != null) {
      nameController.text = passedCrag.name;
      countryController.text = passedCrag.country;
    }
  }

  final TextEditingController nameController = new TextEditingController();
  final TextEditingController countryController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 100,
                child: Text(
                  'Crag',
                ),
              ),
              Flexible(
                child: CupertinoTextField(
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
                ),
              ),
              Flexible(
                child: CupertinoTextField(controller: countryController),
              ),
            ],
          ),
          // buttons below
          SizedBox(
            height: 50,
          ),
          Row(
            children: [
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel'),
              ),
              SizedBox(
                width: 10,
              ),
              CupertinoButton(
                onPressed: () {
                  if (passedCrag != null) {
                    passedCrag.name = nameController.text;
                    passedCrag.country = countryController.text;
                    DatabaseHelper.updateCrag(passedCrag);
                  } else {
                    Crag crag = new Crag(name: nameController.text, country: countryController.text);
                    DatabaseHelper.addCrag(crag);
                  }
                  Navigator.of(context).pop(false);
                },
                child: Text(passedCrag != null ? 'Update' : 'Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
