import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model/ascent.dart';
import 'model/crag.dart';
import 'database.dart';
import 'model/route.dart' as mine;
import 'model/style.dart';
import 'widgets/grade_badge.dart';
import 'widgets/style_chip.dart';

class AddAscentScreen extends StatefulWidget {
  final Ascent? passedAscent;

  AddAscentScreen({Key? key, this.passedAscent});

  @override
  _AddAscentScreenState createState() => _AddAscentScreenState(passedAscent: passedAscent);
}

class _AddAscentScreenState extends State<AddAscentScreen> {
  final Ascent? passedAscent;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController sectorController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  DateTime? currentDate = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  int? styleId = 1;
  String? grade = "6a";
  int? cragId;
  int stars = 0;

  _AddAscentScreenState({this.passedAscent}) {
    if (passedAscent != null) {
      styleId = passedAscent!.style?.id ?? 1;
      grade = passedAscent!.route?.grade ?? "6a";
      cragId = passedAscent!.route?.crag?.id;
      nameController.text = passedAscent!.route?.name ?? '';
      sectorController.text = passedAscent!.route?.sector ?? '';
      currentDate = passedAscent!.date ?? DateTime.now();
      commentController.text = passedAscent!.comment ?? '';
      stars = passedAscent!.stars ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = passedAscent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Ascent" : "Add Ascent"),
        actions: [
          TextButton(
            onPressed: _saveAscent,
            child: Text(
              isEditing ? 'UPDATE' : 'SAVE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Route Info Section
              _buildSectionHeader(context, 'Route Information', Icons.route),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Route Name',
                          hintText: 'Enter route name',
                          prefixIcon: Icon(Icons.label_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a route name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCragDropdown(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: sectorController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Sector (optional)',
                          hintText: 'Enter sector name',
                          prefixIcon: Icon(Icons.map_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Grade & Style Section
              _buildSectionHeader(context, 'Grade & Style', Icons.trending_up),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGradeDropdown(),
                      const SizedBox(height: 16),
                      Text('Style', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _buildStyleSelector(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date & Rating Section
              _buildSectionHeader(context, 'Date & Rating', Icons.calendar_today),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDatePicker(context),
                      const SizedBox(height: 16),
                      Text('Rating', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _buildStarRating(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Comment Section
              _buildSectionHeader(context, 'Notes', Icons.comment_outlined),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: commentController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add notes about this ascent...',
                      border: OutlineInputBorder(),
                    ),
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

  Widget _buildCragDropdown() {
    return FutureBuilder<List>(
      future: DatabaseHelper.getCrags(),
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Crag',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
            child: Text('No crags available', style: TextStyle(color: Colors.grey)),
          );
        }
        return DropdownButtonFormField<int>(
          initialValue: cragId,
          decoration: InputDecoration(
            labelText: 'Crag',
            prefixIcon: Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(),
          ),
          hint: Text("Select a crag"),
          items: snapshot.data!.map((crag) {
            return DropdownMenuItem<int>(
              child: Text(crag.name),
              value: crag.id,
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              cragId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a crag';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildGradeDropdown() {
    return FutureBuilder<List>(
      future: DatabaseHelper.getGrades(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return DropdownButtonFormField<String>(
          initialValue: grade,
          decoration: InputDecoration(
            labelText: 'Grade',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GradeBadge.getGradeColor(grade ?? '6a'),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                grade ?? '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            border: OutlineInputBorder(),
          ),
          items: snapshot.data!.map((g) {
            return DropdownMenuItem<String>(
              value: g,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: GradeBadge.getGradeColor(g),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(g),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              grade = value;
            });
          },
        );
      },
    );
  }

  Widget _buildStyleSelector() {
    final styles = DatabaseHelper.styles;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: styles.map((style) {
        final isSelected = style.id == styleId;
        final config = StyleChip.styleConfigs[style.id];

        return GestureDetector(
          onTap: () => setState(() => styleId = style.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (config?.color ?? Colors.grey).withValues(alpha: 0.15)
                  : Colors.grey[100],
              border: Border.all(
                color: isSelected ? (config?.color ?? Colors.grey) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (config != null)
                  Icon(
                    config.icon,
                    size: 16,
                    color: isSelected ? config.color : Colors.grey[600],
                  ),
                const SizedBox(width: 4),
                Text(
                  style.name!,
                  style: TextStyle(
                    color: isSelected ? (config?.color ?? Colors.grey) : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatter.format(currentDate!),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(3, (index) {
        return GestureDetector(
          onTap: () => setState(() => stars = index + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              index < stars ? Icons.star : Icons.star_border,
              size: 36,
              color: index < stars ? Colors.amber : Colors.grey[400],
            ),
          ),
        );
      })
        ..add(
          GestureDetector(
            onTap: () => setState(() => stars = 0),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ),
        ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
      });
    }
  }

  Future<void> _saveAscent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Crag crag = Crag(id: cragId);
    mine.Route route = mine.Route(
      name: nameController.text,
      crag: crag,
      sector: sectorController.text,
      grade: grade,
    );
    Ascent ascent = Ascent(
      route: route,
      comment: commentController.text,
      date: currentDate,
      attempts: 1,
      stars: stars,
      style: Style(id: styleId),
    );

    if (passedAscent != null) {
      ascent.id = passedAscent!.id;
      ascent.route!.id = passedAscent!.route!.id;
      ascent.route!.crag!.id = cragId;
      await DatabaseHelper.updateAscent(ascent);
    } else {
      await DatabaseHelper.addAscent(ascent);
    }

    Navigator.pop(context);
  }
}
