import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

class TabModel {
  final String label;
  final bool disabled;
  final Widget view;

  TabModel({required this.label, required this.view, this.disabled = false});
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<TabModel> tabs;
  final void Function(int index) onTap;

  const CustomTabBar({super.key, required this.tabController, required this.tabs, required this.onTap});

  void safeOnTap(int index) => onTap(tabs[index].disabled ? tabController.previousIndex : index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceDim,
      child: TabBar(
        padding: EdgeInsets.symmetric(horizontal: 4),
        indicatorColor: theme.colorScheme.secondary,
        dividerColor: ThemeColors.textLight,
        dividerHeight: 2,
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: safeOnTap,
        tabs: tabs
            .map(
              (tab) => Tab(
                child: Text(
                  tab.label,
                  style: tab.disabled ? TextStyle(color: ThemeColors.textDisabled) : null,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
