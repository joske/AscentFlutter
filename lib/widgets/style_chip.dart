import 'package:flutter/material.dart';
import '../model/style.dart';

class StyleConfig {
  final Color color;
  final IconData icon;
  final String label;

  const StyleConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}

class StyleChip extends StatelessWidget {
  final Style style;

  const StyleChip({super.key, required this.style});

  static const Map<int, StyleConfig> styleConfigs = {
    1: StyleConfig(
      color: Color(0xFF2E7D32),
      icon: Icons.visibility,
      label: 'OS',
    ), // OnSight - Green
    2: StyleConfig(
      color: Color(0xFFF9A825),
      icon: Icons.flash_on,
      label: 'FL',
    ), // Flash - Yellow
    3: StyleConfig(
      color: Color(0xFFD32F2F),
      icon: Icons.check_circle,
      label: 'RP',
    ), // Redpoint - Red
    4: StyleConfig(
      color: Color(0xFF757575),
      icon: Icons.arrow_upward,
      label: 'TP',
    ), // Toprope - Grey
    5: StyleConfig(
      color: Color(0xFF9E9E9E),
      icon: Icons.repeat,
      label: 'Rep',
    ), // Repeat - Light grey
    6: StyleConfig(
      color: Color(0xFF5D4037),
      icon: Icons.terrain,
      label: 'MP',
    ), // Multipitch - Brown
    7: StyleConfig(
      color: Color(0xFFBDBDBD),
      icon: Icons.hourglass_empty,
      label: 'AT',
    ), // Tried - Light grey
  };

  @override
  Widget build(BuildContext context) {
    final config = styleConfigs[style.id] ??
        const StyleConfig(
          color: Colors.grey,
          icon: Icons.help,
          label: '?',
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        border: Border.all(color: config.color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
