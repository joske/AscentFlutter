import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

/// An adaptive segmented control / tab bar
/// Uses CupertinoSlidingSegmentedControl on iOS and is embedded in the body
/// Uses TabBar on Android which goes in the AppBar bottom
class AdaptiveSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final List<String> segments;
  final ValueChanged<int> onValueChanged;
  final TabController? tabController;

  const AdaptiveSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.segments,
    required this.onValueChanged,
    this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CupertinoSlidingSegmentedControl<int>(
          groupValue: selectedIndex,
          children: {
            for (int i = 0; i < segments.length; i++)
              i: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(segments[i]),
              ),
          },
          onValueChanged: (value) => onValueChanged(value!),
        ),
      );
    }

    // On Android, return empty - TabBar should be in AppBar.bottom
    return const SizedBox.shrink();
  }

  /// Creates a TabBar for use in AppBar.bottom on Android
  static PreferredSizeWidget? buildTabBar({
    required List<String> segments,
    required TabController controller,
  }) {
    if (PlatformUtils.isIOS) return null;

    return TabBar(
      controller: controller,
      tabs: segments.map((s) => Tab(text: s)).toList(),
    );
  }
}
