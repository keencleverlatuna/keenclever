import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../widgets/glass_bottom_navigation.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      const HomeScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0B0F17)
        : const Color(0xFFEAF4FF);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor:
        Colors.transparent,
        systemNavigationBarDividerColor:
        Colors.transparent,
        systemNavigationBarIconBrightness:
        isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced:
        false,
      ),
      child: GlassScaffold(
        extendBody: true,
        contentAwareBrightness: true,
        backgroundColor: backgroundColor,
        bottomBar: GlassBottomNavigation(
          selectedIndex: selectedIndex,
          onTabSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: backgroundColor,
          child: IndexedStack(
            index: selectedIndex,
            children: screens,
          ),
        ),
      ),
    );
  }
}
