import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

/// An adaptive scaffold that uses CupertinoPageScaffold on iOS and Scaffold on Android
class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? trailing;
  final VoidCallback? onTrailingPressed;
  final Widget? floatingActionButton;
  final String? previousPageTitle;
  final PreferredSizeWidget? bottom;

  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.trailing,
    this.onTrailingPressed,
    this.floatingActionButton,
    this.previousPageTitle,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          previousPageTitle: previousPageTitle,
          trailing: trailing != null
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onTrailingPressed,
                  child: trailing!,
                )
              : null,
        ),
        child: SafeArea(child: body),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: trailing != null
            ? [
                IconButton(
                  icon: trailing!,
                  onPressed: onTrailingPressed,
                ),
              ]
            : null,
        bottom: bottom,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// A simpler adaptive scaffold for screens embedded in tabs (no nav bar needed on iOS)
class AdaptiveTabBody extends StatelessWidget {
  final Widget child;
  final bool needsMaterial;

  const AdaptiveTabBody({
    super.key,
    required this.child,
    this.needsMaterial = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS && needsMaterial) {
      return Material(
        type: MaterialType.transparency,
        child: SafeArea(child: child),
      );
    }
    if (PlatformUtils.isIOS) {
      return SafeArea(child: child);
    }
    return child;
  }
}
