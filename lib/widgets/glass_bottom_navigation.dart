import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class GlassBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const GlassBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final selectedColor =
    isDark ? Colors.white : Colors.black87;

    final unselectedColor =
    isDark
        ? Colors.white.withValues(alpha: 0.75)
        : Colors.black54;

    return GlassTabBar.bottom(
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected,
      showIndicator: true,
      interactionBehavior:
      GlassInteractionBehavior.full,
      enableBlend: true,
      indicatorPinchStrength: 0.55,
      indicatorExpansion:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 9,
      ),
      magnification: 1.18,
      barHeight: 70,
      barBorderRadius: 36,
      horizontalPadding: 16,
      verticalPadding: 16,
      tabPadding:
      const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      iconSize: 25,
      labelFontSize: 11,
      selectedIconColor: selectedColor,
      selectedLabelColor: selectedColor,
      unselectedIconColor: unselectedColor,
      unselectedLabelColor: unselectedColor,
      tabs: const [
        GlassTab(
          icon: Icon(
            CupertinoIcons.creditcard,
          ),
          activeIcon: Icon(
            CupertinoIcons.creditcard_fill,
          ),
          label: 'Accounts',
        ),
        GlassTab(
          icon: Icon(
            CupertinoIcons.gear,
          ),
          activeIcon: Icon(
            CupertinoIcons.gear_solid,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}