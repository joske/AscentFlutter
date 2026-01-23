import 'package:flutter/cupertino.dart';

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
    final isEditing = widget.passedCrag != null;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                isEditing ? 'Edit Crag' : 'Add Crag',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(
                  isEditing ? 'Update' : 'Add',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: _saveCrag,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Form
          CupertinoFormSection.insetGrouped(
            header: Text('CRAG DETAILS'),
            children: [
              CupertinoTextFormFieldRow(
                controller: nameController,
                prefix: Text('Name'),
                placeholder: 'e.g. Margalef',
                textCapitalization: TextCapitalization.words,
              ),
              CupertinoTextFormFieldRow(
                controller: countryController,
                prefix: Text('Country'),
                placeholder: 'e.g. BEL, FRA, ESP',
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ],
      ),
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
