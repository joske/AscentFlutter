import 'dart:io';

import 'package:ascent/model/gradeinfo.dart';
import 'package:ascent/widgets/grade_badge.dart';
import 'package:flutter/material.dart';
import 'database.dart';

class PyramidScreen extends StatefulWidget {
  @override
  _PyramidScreenState createState() => _PyramidScreenState();
}

class _PyramidScreenState extends State<PyramidScreen> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Material(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 50),
            child: _buildBody(context),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Pyramid'),
      ),
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

        final grades = snapshot.data!;
        if (grades.isEmpty) {
          return const Center(child: Text('No ascents yet'));
        }

        final maxTotal = grades.map((g) => g.getTotal()).reduce((a, b) => a > b ? a : b);

        return Column(
          children: [
            _buildLegend(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: grades.map((g) => _buildPyramidRow(g, maxTotal)).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem('OS', const Color(0xFF2E7D32)),
          const SizedBox(width: 20),
          _legendItem('FL', const Color(0xFFF9A825)),
          const SizedBox(width: 20),
          _legendItem('RP', const Color(0xFFD32F2F)),
          const SizedBox(width: 20),
          _legendItem('TP', const Color(0xFF757575)),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey[400]!, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _buildPyramidRow(Gradeinfo grade, int maxTotal) {
    final total = grade.getTotal();
    final barWidth = maxTotal > 0 ? total / maxTotal : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Grade badge
          SizedBox(
            width: 56,
            child: GradeBadge(grade: grade.grade),
          ),
          const SizedBox(width: 12),
          // Pyramid bar
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final totalBarWidth = availableWidth * barWidth;

                return Stack(
                  children: [
                    // Background
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Centered pyramid bar
                    Center(
                      child: Container(
                        width: totalBarWidth,
                        height: 28,
                        child: _buildStackedBar(grade, totalBarWidth),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Total count
          SizedBox(
            width: 36,
            child: Text(
              total.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedBar(Gradeinfo grade, double totalWidth) {
    final total = grade.getTotal();
    if (total == 0 || totalWidth <= 0) return const SizedBox();

    final osWidth = (grade.osCount / total) * totalWidth;
    final flWidth = (grade.flCount / total) * totalWidth;
    final rpWidth = (grade.rpCount / total) * totalWidth;
    final tpWidth = (grade.tpCount / total) * totalWidth;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (tpWidth > 0)
            Container(width: tpWidth / 2, color: const Color(0xFF757575)),
          if (rpWidth > 0)
            Container(width: rpWidth / 2, color: const Color(0xFFD32F2F)),
          if (flWidth > 0)
            Container(width: flWidth / 2, color: const Color(0xFFF9A825)),
          if (osWidth > 0)
            Container(width: osWidth, color: const Color(0xFF2E7D32)),
          if (flWidth > 0)
            Container(width: flWidth / 2, color: const Color(0xFFF9A825)),
          if (rpWidth > 0)
            Container(width: rpWidth / 2, color: const Color(0xFFD32F2F)),
          if (tpWidth > 0)
            Container(width: tpWidth / 2, color: const Color(0xFF757575)),
        ],
      ),
    );
  }
}
