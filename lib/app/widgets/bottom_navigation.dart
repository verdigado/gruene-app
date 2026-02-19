import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/bottom_navigation_items.dart';
import 'package:gruene_app/app/enums/badge_source.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/icon.dart';
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';

class BottomNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigation({super.key, required this.navigationShell});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final campaignValueStore = GetIt.I<CampaignValueStore>();

  @override
  void initState() {
    campaignValueStore.addListener(_onCampaignValueStoreChange);
    super.initState();
  }

  @override
  dispose() {
    campaignValueStore.removeListener(_onCampaignValueStoreChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = bottomNavigationItems.map((item) {
      final isSelected = bottomNavigationItems.indexOf(item) == widget.navigationShell.currentIndex;
      final color = isSelected ? theme.colorScheme.primary : ThemeColors.textDisabled;
      var icon = item.icon != null
          ? Icon(item.icon, size: 32, color: color)
          : SizedBox(
              height: 32,
              width: 32,
              child: Center(
                child: CustomIcon(path: item.assetIcon!, width: 28, height: 28, color: color),
              ),
            );
      switch (item.badgeSource) {
        case BadgeSource.openInvitations:
          if (campaignValueStore.openInvitations > 0) {
            icon = Badge(child: icon);
          }
          break;
        case BadgeSource.none:
          break;
      }
      return BottomNavigationBarItem(icon: icon, label: item.label);
    }).toList();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      items: items,
      currentIndex: widget.navigationShell.currentIndex,
      onTap: (index) =>
          widget.navigationShell.goBranch(index, initialLocation: index == widget.navigationShell.currentIndex),
    );
  }

  void _onCampaignValueStoreChange() {
    setState(() {});
  }
}
