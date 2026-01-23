import 'dart:io';

import 'package:ascent/util.dart';
import 'package:ascent/widgets/ascent_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/ascent.dart';
import 'model/gradeinfo.dart';
import 'database.dart';
import 'widgets/grade_chart.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Material(
        child: Container(
          padding: EdgeInsets.only(top: 100.0, bottom: 100),
          child: buildBody(context),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return FutureBuilder<List<Gradeinfo>>(
      future: DatabaseHelper.getGradeInfos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final gradeInfos = snapshot.data!;
        final totalAscents = gradeInfos.fold<int>(0, (sum, info) => sum + info.getTotal());
        final totalOS = gradeInfos.fold<int>(0, (sum, info) => sum + info.osCount);
        final totalFL = gradeInfos.fold<int>(0, (sum, info) => sum + info.flCount);
        final totalRP = gradeInfos.fold<int>(0, (sum, info) => sum + info.rpCount);
        final totalTP = gradeInfos.fold<int>(0, (sum, info) => sum + info.tpCount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(totalAscents, totalOS, totalFL, totalRP, totalTP),
              const SizedBox(height: 24),
              Text(
                'Ascents by Grade',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const ChartLegend(),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: GradeChart(gradeInfos: gradeInfos.reversed.toList()),
              ),
              const SizedBox(height: 24),
              Text(
                'Grade Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildGradeTable(context, gradeInfos),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(int total, int os, int fl, int rp, int tp) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total', total.toString(), Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('OS', os.toString(), const Color(0xFF2E7D32))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('FL', fl.toString(), const Color(0xFFF9A825))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('RP', rp.toString(), const Color(0xFFD32F2F))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('TP', tp.toString(), const Color(0xFF757575))),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeTable(BuildContext context, List<Gradeinfo> gradeInfos) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              children: [
                _tableHeader('Grade'),
                _tableHeader('OS'),
                _tableHeader('FL'),
                _tableHeader('RP'),
                _tableHeader('TP'),
                _tableHeader('Total'),
              ],
            ),
            ...gradeInfos.map((info) => TableRow(
                  children: [
                    _gradeCell(context, info.grade),
                    _tableCell(info.osCount.toString(), color: const Color(0xFF2E7D32)),
                    _tableCell(info.flCount.toString(), color: const Color(0xFFF9A825)),
                    _tableCell(info.rpCount.toString(), color: const Color(0xFFD32F2F)),
                    _tableCell(info.tpCount.toString(), color: const Color(0xFF757575)),
                    _tableCell(info.getTotal().toString(), isBold: true),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _gradeCell(BuildContext context, String grade) {
    return InkWell(
      onTap: () => _showGradeDetail(context, grade),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Text(
          grade,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showGradeDetail(BuildContext context, String grade) {
    if (Platform.isIOS) {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, _, __) {
            return FullDialogPage(grade);
          },
        ),
      );
    } else {
      _showMaterialDetail(context, grade);
    }
  }

  void _showMaterialDetail(BuildContext context, String grade) async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showMaterialDialog(
      context,
      'Grade $grade',
      await _buildDetailContent(grade),
      <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        )
      ],
      height - 100,
      width,
    );
  }

  Future<Widget> _buildDetailContent(String grade) async {
    return FutureBuilder<List<Ascent>>(
      future: DatabaseHelper.getAscentsWhere("route_grade = ?", [grade]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return AscentCard(
              ascent: snapshot.data![index],
              trailing: const SizedBox(width: 8),
            );
          },
        );
      },
    );
  }
}

class FullDialogPage extends StatefulWidget {
  final String grade;
  FullDialogPage(this.grade);

  @override
  _FullDialogPageState createState() => _FullDialogPageState();
}

class _FullDialogPageState extends State<FullDialogPage> with TickerProviderStateMixin {
  late AnimationController _primary, _secondary;
  late Animation<double> _animationPrimary, _animationSecondary;

  @override
  void initState() {
    _primary = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationPrimary = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _primary, curve: Curves.easeOut));
    _secondary = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationSecondary = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _secondary, curve: Curves.easeOut));
    _primary.forward();
    super.initState();
  }

  @override
  void dispose() {
    _primary.dispose();
    _secondary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoFullscreenDialogTransition(
      primaryRouteAnimation: _animationPrimary,
      secondaryRouteAnimation: _animationSecondary,
      linearTransition: false,
      child: Container(
        padding: EdgeInsets.only(top: 100, bottom: 100),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Grade ${widget.grade}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: FutureBuilder<List<Ascent>>(
                future: DatabaseHelper.getAscentsWhere("route_grade = ?", [widget.grade]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return AscentCard(
                        ascent: snapshot.data![index],
                        trailing: const SizedBox(width: 8),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                CupertinoButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
