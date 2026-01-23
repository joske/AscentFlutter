import 'package:ascent/util.dart';
import 'package:ascent/widgets/adaptive/adaptive.dart';
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
    // Overview is embedded in a tab on iOS
    if (PlatformUtils.isIOS) {
      return AdaptiveTabBody(child: _buildBody(context));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Summary')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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
              Text('Ascents by Grade', style: _titleStyle(context)),
              const SizedBox(height: 8),
              const ChartLegend(),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: GradeChart(gradeInfos: gradeInfos.reversed.toList()),
              ),
              const SizedBox(height: 24),
              Text('Grade Breakdown', style: _titleStyle(context)),
              const SizedBox(height: 8),
              _buildGradeTable(context, gradeInfos),
            ],
          ),
        );
      },
    );
  }

  TextStyle _titleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: PlatformUtils.textColor(context),
    );
  }

  Widget _buildSummaryCards(int total, int os, int fl, int rp, int tp) {
    return Row(
      children: [
        Expanded(child: AdaptiveStatCard(label: 'Total', value: total.toString(), color: Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: AdaptiveStatCard(label: 'OS', value: os.toString(), color: const Color(0xFF2E7D32))),
        const SizedBox(width: 8),
        Expanded(child: AdaptiveStatCard(label: 'FL', value: fl.toString(), color: const Color(0xFFF9A825))),
        const SizedBox(width: 8),
        Expanded(child: AdaptiveStatCard(label: 'RP', value: rp.toString(), color: const Color(0xFFD32F2F))),
        const SizedBox(width: 8),
        Expanded(child: AdaptiveStatCard(label: 'TP', value: tp.toString(), color: const Color(0xFF757575))),
      ],
    );
  }

  Widget _buildGradeTable(BuildContext context, List<Gradeinfo> gradeInfos) {
    final isDark = PlatformUtils.isDarkMode(context);

    return AdaptiveCard(
      margin: EdgeInsets.zero,
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
              border: Border(bottom: BorderSide(color: PlatformUtils.dividerColor(context))),
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
                  _tableCell(info.tpCount.toString(), color: isDark ? Colors.grey[400] : const Color(0xFF757575)),
                  _tableCell(info.getTotal().toString(), isBold: true),
                ],
              )),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: PlatformUtils.textColor(context),
        ),
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
          color: color ?? PlatformUtils.textColor(context),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showGradeDetail(BuildContext context, String grade) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _GradeDetailPage(grade: grade),
      ),
    );
  }
}

class _GradeDetailPage extends StatelessWidget {
  final String grade;

  const _GradeDetailPage({required this.grade});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Grade $grade',
      previousPageTitle: 'Summary',
      body: FutureBuilder<List<Ascent>>(
        future: DatabaseHelper.getAscentsWhere("route_grade = ?", [grade]),
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
    );
  }
}
