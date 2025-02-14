import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/bottom_navigation_items.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/icon.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final topRoute = GoRouter.of(context).routerDelegate.currentConfiguration.matches[0].route as GoRoute;
    final topRouteIndex = bottomNavigationItems.indexWhere((item) => item.route == topRoute.path);
    final visible = topRouteIndex != -1;
    final theme = Theme.of(context);

    if (!visible) {
      return SizedBox.shrink();
    }

    final items = bottomNavigationItems.map((item) {
      final isSelected = item.route == topRoute.path;
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
        currentIndex: topRouteIndex,
        onTap: (index) => context.go(bottomNavigationItems[index].route),
      ),
    );
  }
}
