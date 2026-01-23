import 'dart:io';
import 'package:flutter/material.dart';

/// Utility class for platform and theme detection
class PlatformUtils {
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  static bool isDarkMode(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  static Color cardColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[850]! : Colors.white;
  }

  static Color backgroundColor(BuildContext context) {
    return isDarkMode(context) ? Colors.black : Colors.white;
  }

  static Color textColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black87;
  }

  static Color secondaryTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[400]! : Colors.grey[600]!;
  }

  static Color dividerColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[700]! : Colors.grey[300]!;
  }
}
