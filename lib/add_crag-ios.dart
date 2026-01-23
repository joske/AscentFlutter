import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/crag.dart';
import 'database.dart';

class CupertinoAddCragScreen extends StatefulWidget {
  final Crag? passedCrag;

  CupertinoAddCragScreen({this.passedCrag});

  @override
  _CupertinoAddCragScreenState createState() => _CupertinoAddCragScreenState();
}

class _CupertinoAddCragScreenState extends State<CupertinoAddCragScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.passedCrag != null) {
      nameController.text = widget.passedCrag!.name ?? '';
      countryController.text = widget.passedCrag!.country ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ListView(
      children: <Widget>[
        // Form
        CupertinoFormSection.insetGrouped(
          header: Text('CRAG DETAILS'),
          children: [
            CupertinoTextFormFieldRow(
              controller: nameController,
              prefix: Text('Name'),
              placeholder: 'e.g. Margalef',
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: textColor),
            ),
            CupertinoTextFormFieldRow(
              controller: countryController,
              prefix: Text('Country'),
              placeholder: 'e.g. BEL, FRA, ESP',
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CupertinoButton.filled(
            onPressed: _saveCrag,
            child: Text(widget.passedCrag != null ? 'Update' : 'Add'),
          ),
        ),
      ],
    );
  }

  void _saveCrag() {
    if (nameController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Missing Information'),
          content: Text('Please enter a crag name'),
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

    if (widget.passedCrag != null) {
      widget.passedCrag!.name = nameController.text;
      widget.passedCrag!.country = countryController.text;
      DatabaseHelper.updateCrag(widget.passedCrag!);
    } else {
      Crag crag = Crag(name: nameController.text, country: countryController.text);
      DatabaseHelper.addCrag(crag);
    }
    Navigator.of(context).pop(false);
  }
}
