import 'package:flutter/material.dart';

import 'model/crag.dart';
import 'database.dart';

class AddCragScreen extends StatefulWidget {
  final Crag? passedCrag;

  AddCragScreen({this.passedCrag});

  @override
  _AddCragScreenState createState() => _AddCragScreenState();
}

class _AddCragScreenState extends State<AddCragScreen> {
  final _formKey = GlobalKey<FormState>();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Crag" : "Add Crag"),
        actions: [
          TextButton(
            onPressed: _saveCrag,
            child: Text(
              isEditing ? 'UPDATE' : 'SAVE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSectionHeader(context, 'Crag Details', Icons.location_on),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Crag Name',
                          hintText: 'e.g. Margalef, Frankenjura',
                          prefixIcon: Icon(Icons.terrain),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a crag name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: countryController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Country',
                          hintText: 'e.g. BEL, FRA, ESP',
                          prefixIcon: Icon(Icons.flag_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  void _saveCrag() {
    if (!_formKey.currentState!.validate()) {
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
    Navigator.pop(context);
  }
}
