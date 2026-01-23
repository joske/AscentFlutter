import 'package:flutter/material.dart';

class GradeBadge extends StatelessWidget {
  final String grade;

  const GradeBadge({super.key, required this.grade});

  static Color getGradeColor(String grade) {
    const gradeColors = {
      '3': Color(0xFF81C784),
      '4': Color(0xFF66BB6A),
      '5a': Color(0xFF4CAF50),
      '5b': Color(0xFF26A69A),
      '5c': Color(0xFF009688),
      '6a': Color(0xFF42A5F5),
      '6a+': Color(0xFF2196F3),
      '6b': Color(0xFF1E88E5),
      '6b+': Color(0xFF5C6BC0),
      '6c': Color(0xFF3F51B5),
      '6c+': Color(0xFF7E57C2),
      '7a': Color(0xFF9C27B0),
      '7a+': Color(0xFF8E24AA),
      '7b': Color(0xFF7B1FA2),
      '7b+': Color(0xFF6A1B9A),
      '7c': Color(0xFFFB8C00),
      '7c+': Color(0xFFF57C00),
      '8a': Color(0xFFFF5722),
      '8a+': Color(0xFFF4511E),
      '8b': Color(0xFFE53935),
      '8b+': Color(0xFFD32F2F),
      '8c': Color(0xFFC62828),
      '8c+': Color(0xFFB71C1C),
      '9a': Color(0xFF8B0000),
      '9a+': Color(0xFF7B0000),
      '9b': Color(0xFF6B0000),
      '9b+': Color(0xFF5B0000),
      '9c': Color(0xFF4B0000),
      '9c+': Color(0xFF3B0000),
      '10a': Color(0xFF2B0000),
      '10a+': Color(0xFF1B0000),
      '10b': Color(0xFF150000),
      '10b+': Color(0xFF100000),
      '10c': Color(0xFF0A0000),
      '10c+': Color(0xFF050000),
    };

    return gradeColors[grade] ?? Colors.grey;
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.4 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final color = getGradeColor(grade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: _getContrastColor(color),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
