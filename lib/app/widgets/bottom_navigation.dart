import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/bottom_navigation_items.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/icon.dart';

class BottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = bottomNavigationItems.map((item) {
      final isSelected = bottomNavigationItems.indexOf(item) == navigationShell.currentIndex;
      final color = isSelected ? theme.colorScheme.primary : ThemeColors.textDisabled;
      final icon = item.icon != null
          ? Icon(item.icon, size: 32, color: color)
          : SizedBox(
              height: 32,
              width: 32,
              child: Center(
                child: CustomIcon(path: item.assetIcon!, width: 28, height: 28, color: color),
              ),
            );
      return BottomNavigationBarItem(icon: icon, label: item.label);
    }).toList();

    return SizedBox(
      height: 64,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        items: items,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      ),
    );
  }
}
