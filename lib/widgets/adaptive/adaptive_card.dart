import 'package:flutter/material.dart';
import 'platform_utils.dart';

/// A card that automatically adapts to dark mode
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final Color? topBorderColor;
  final double topBorderWidth;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.elevation = 2,
    this.topBorderColor,
    this.topBorderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = PlatformUtils.isDarkMode(context);

    return Card(
      elevation: elevation,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isDark ? Colors.grey[850] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: padding,
        decoration: topBorderColor != null
            ? BoxDecoration(
                border: Border(
                  top: BorderSide(color: topBorderColor!, width: topBorderWidth),
                ),
              )
            : null,
        child: child,
      ),
    );
  }
}

/// A stat card with a colored top border (used in summary screens)
class AdaptiveStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const AdaptiveStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = PlatformUtils.isDarkMode(context);

    return AdaptiveCard(
      margin: EdgeInsets.zero,
      topBorderColor: color,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
