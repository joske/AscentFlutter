import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model/ascent.dart';
import 'model/crag.dart';
import 'database.dart';
import 'model/route.dart' as mine;
import 'model/style.dart';
import 'widgets/grade_badge.dart';
import 'widgets/style_chip.dart';

class CupertinoAddAscentScreen extends StatefulWidget {
  final Ascent? passedAscent;

  CupertinoAddAscentScreen({Key? key, this.passedAscent});

  @override
  _CupertinoAddAscentScreenState createState() => _CupertinoAddAscentScreenState(passedAscent: passedAscent);
}

class _CupertinoAddAscentScreenState extends State<CupertinoAddAscentScreen> {
  final Ascent? passedAscent;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController sectorController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  DateTime? currentDate = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  int? styleId = 1;
  String? grade = "6a";
  var cragId;
  int stars = 0;
  var cragIndex = 0;
  var gradeIndex = 0;
  List<Crag>? crags;
  List<String>? grades;

  _CupertinoAddAscentScreenState({this.passedAscent}) {
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

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? "Edit Ascent" : "Add Ascent"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            isEditing ? 'Update' : 'Save',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onPressed: _saveAscent,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Route Information Section
              _buildSectionHeader('Route Information'),
              CupertinoFormSection.insetGrouped(
                children: [
                  CupertinoTextFormFieldRow(
                    controller: nameController,
                    prefix: Text('Name'),
                    placeholder: 'Route name',
                    textCapitalization: TextCapitalization.words,
                  ),
                  _buildCragPicker(),
                  CupertinoTextFormFieldRow(
                    controller: sectorController,
                    prefix: Text('Sector'),
                    placeholder: 'Optional',
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Grade & Style Section
              _buildSectionHeader('Grade & Style'),
              CupertinoFormSection.insetGrouped(
                children: [
                  _buildGradePicker(),
                  _buildStylePicker(),
                ],
              ),

              const SizedBox(height: 20),

              // Date & Rating Section
              _buildSectionHeader('Date & Rating'),
              CupertinoFormSection.insetGrouped(
                children: [
                  _buildDatePicker(),
                  CupertinoFormRow(
                    prefix: Text('Rating'),
                    child: _buildStarRating(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Notes Section
              _buildSectionHeader('Notes'),
              CupertinoFormSection.insetGrouped(
                children: [
                  CupertinoTextFormFieldRow(
                    controller: commentController,
                    placeholder: 'Add notes about this ascent...',
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          color: CupertinoColors.systemGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCragPicker() {
    return FutureBuilder<List<Crag>>(
      future: DatabaseHelper.getCrags(),
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return CupertinoFormRow(
            prefix: Text('Crag'),
            child: Text('No crags available', style: TextStyle(color: CupertinoColors.systemGrey)),
          );
        }
        crags = snapshot.data;
        if (passedAscent != null && cragId != null) {
          final c = crags!.firstWhere((element) => element.id == cragId, orElse: () => crags!.first);
          cragIndex = crags!.indexOf(c);
        }
        return GestureDetector(
          onTap: () => _showCragPicker(context),
          child: CupertinoFormRow(
            prefix: Text('Crag'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  crags![cragIndex].name ?? 'Select',
                  style: TextStyle(color: CupertinoColors.systemBlue),
                ),
                const SizedBox(width: 4),
                Icon(CupertinoIcons.chevron_down, size: 16, color: CupertinoColors.systemGrey),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCragPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: cragIndex),
                itemExtent: 32,
                onSelectedItemChanged: (value) {
                  setState(() => cragIndex = value);
                },
                children: crags!.map((crag) => Center(child: Text(crag.name ?? ''))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradePicker() {
    return FutureBuilder<List<String>>(
      future: DatabaseHelper.getGrades(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CupertinoFormRow(
            prefix: Text('Grade'),
            child: CupertinoActivityIndicator(),
          );
        }
        grades = snapshot.data;
        if (grade != null) {
          gradeIndex = grades!.indexOf(grade!);
          if (gradeIndex < 0) gradeIndex = 0;
        }
        return GestureDetector(
          onTap: () => _showGradePicker(context),
          child: CupertinoFormRow(
            prefix: Text('Grade'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: GradeBadge.getGradeColor(grade ?? '6a'),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    grade ?? '?',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(CupertinoIcons.chevron_down, size: 16, color: CupertinoColors.systemGrey),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGradePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: gradeIndex),
                itemExtent: 32,
                onSelectedItemChanged: (value) {
                  setState(() {
                    gradeIndex = value;
                    grade = grades![value];
                  });
                },
                children: grades!.map((g) => Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: GradeBadge.getGradeColor(g),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(g),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylePicker() {
    final styles = DatabaseHelper.styles;
    final currentStyle = styles.firstWhere((s) => s.id == styleId, orElse: () => styles.first);
    final config = StyleChip.styleConfigs[styleId];

    return GestureDetector(
      onTap: () => _showStylePicker(context),
      child: CupertinoFormRow(
        prefix: Text('Style'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (config?.color ?? CupertinoColors.systemGrey).withValues(alpha: 0.15),
                border: Border.all(color: config?.color ?? CupertinoColors.systemGrey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (config != null) Icon(config.icon, size: 14, color: config.color),
                  const SizedBox(width: 4),
                  Text(
                    currentStyle.name ?? '',
                    style: TextStyle(color: config?.color ?? CupertinoColors.systemGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(CupertinoIcons.chevron_down, size: 16, color: CupertinoColors.systemGrey),
          ],
        ),
      ),
    );
  }

  void _showStylePicker(BuildContext context) {
    final styles = DatabaseHelper.styles;
    int styleIndex = styles.indexWhere((s) => s.id == styleId);
    if (styleIndex < 0) styleIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: styleIndex),
                itemExtent: 32,
                onSelectedItemChanged: (value) {
                  setState(() => styleId = styles[value].id);
                },
                children: styles.map((style) {
                  final config = StyleChip.styleConfigs[style.id];
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (config != null) Icon(config.icon, size: 18, color: config.color),
                        const SizedBox(width: 8),
                        Text(style.name ?? ''),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: CupertinoFormRow(
        prefix: Text('Date'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              formatter.format(currentDate!),
              style: TextStyle(color: CupertinoColors.systemBlue),
            ),
            const SizedBox(width: 4),
            Icon(CupertinoIcons.chevron_down, size: 16, color: CupertinoColors.systemGrey),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    DateTime? pickedDate = currentDate;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () {
                      setState(() => currentDate = pickedDate);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: currentDate,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (val) => pickedDate = val,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...List.generate(3, (index) {
          return GestureDetector(
            onTap: () => setState(() => stars = stars == index + 1 ? 0 : index + 1),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                index < stars ? CupertinoIcons.star_fill : CupertinoIcons.star,
                size: 28,
                color: index < stars ? Colors.amber : CupertinoColors.systemGrey3,
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _saveAscent() async {
    if (nameController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Missing Information'),
          content: Text('Please enter a route name'),
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

    if (crags == null || crags!.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Missing Information'),
          content: Text('Please add a crag first'),
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

    Crag crag = crags![cragIndex];
    if (grades != null && grades!.isNotEmpty) {
      grade = grades![gradeIndex];
    }

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
