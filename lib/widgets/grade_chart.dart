import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../model/gradeinfo.dart';
import 'grade_badge.dart';

class GradeChart extends StatelessWidget {
  final List<Gradeinfo> gradeInfos;

  const GradeChart({super.key, required this.gradeInfos});

  @override
  Widget build(BuildContext context) {
    if (gradeInfos.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final grade = gradeInfos[group.x.toInt()];
              return BarTooltipItem(
                '${grade.grade}\nOS: ${grade.osCount}  FL: ${grade.flCount}\nRP: ${grade.rpCount}  TP: ${grade.tpCount}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= gradeInfos.length) return const SizedBox();
                final grade = gradeInfos[value.toInt()].grade;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Text(
                      grade,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: GradeBadge.getGradeColor(grade),
                      ),
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == value.roundToDouble()) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getInterval(),
        ),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var info in gradeInfos) {
      final total = info.getTotal();
      if (total > max) max = total.toDouble();
    }
    return (max * 1.2).ceilToDouble();
  }

  double _getInterval() {
    final max = _getMaxY();
    if (max <= 5) return 1;
    if (max <= 20) return 5;
    if (max <= 50) return 10;
    return 20;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return gradeInfos.asMap().entries.map((entry) {
      final index = entry.key;
      final info = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: info.getTotal().toDouble(),
            width: 12,
            rodStackItems: [
              BarChartRodStackItem(0, info.osCount.toDouble(), const Color(0xFF2E7D32)),
              BarChartRodStackItem(
                info.osCount.toDouble(),
                (info.osCount + info.flCount).toDouble(),
                const Color(0xFFF9A825),
              ),
              BarChartRodStackItem(
                (info.osCount + info.flCount).toDouble(),
                (info.osCount + info.flCount + info.rpCount).toDouble(),
                const Color(0xFFD32F2F),
              ),
              BarChartRodStackItem(
                (info.osCount + info.flCount + info.rpCount).toDouble(),
                info.getTotal().toDouble(),
                const Color(0xFF757575),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('OS', const Color(0xFF2E7D32)),
        const SizedBox(width: 16),
        _legendItem('FL', const Color(0xFFF9A825)),
        const SizedBox(width: 16),
        _legendItem('RP', const Color(0xFFD32F2F)),
        const SizedBox(width: 16),
        _legendItem('TP', const Color(0xFF757575)),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
