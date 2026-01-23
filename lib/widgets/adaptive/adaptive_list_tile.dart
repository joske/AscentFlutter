import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

/// An adaptive list tile that uses CupertinoListTile on iOS and ListTile on Android
class AdaptiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const AdaptiveListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: showChevron
            ? const CupertinoListTileChevron()
            : trailing,
        onTap: onTap,
      );
    }

    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// A menu item for the "More" screen or drawers
class AdaptiveMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const AdaptiveMenuItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoListTile(
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(title),
        trailing: const CupertinoListTileChevron(),
        onTap: onTap,
      );
    }

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
