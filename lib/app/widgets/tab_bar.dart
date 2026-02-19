import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/enums/badge_source.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';

class TabModelBase {
  final String label;
  final bool disabled;
  final BadgeSource badgeSource;

  TabModelBase({required this.label, this.disabled = false, this.badgeSource = BadgeSource.none});
}

class TabModel extends TabModelBase {
  final Widget view;

  TabModel({required super.label, required this.view, super.disabled, super.badgeSource});
}

class CustomTabBar extends StatefulWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<TabModelBase> tabs;
  final void Function(int index) onTap;

  const CustomTabBar({super.key, required this.tabController, required this.tabs, required this.onTap});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

class _CustomTabBarState extends State<CustomTabBar> {
  final campaignValueStore = GetIt.I<CampaignValueStore>();
  void safeOnTap(int index) => widget.onTap(widget.tabs[index].disabled ? widget.tabController.previousIndex : index);

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
    return Material(
      color: theme.colorScheme.surfaceDim,
      child: TabBar(
        padding: EdgeInsets.symmetric(horizontal: 4),
        indicatorColor: theme.colorScheme.secondary,
        dividerColor: ThemeColors.textLight,
        dividerHeight: 2,
        controller: widget.tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: safeOnTap,
        tabs: widget.tabs.map((tab) {
          Widget tabWidget = Text(tab.label, style: tab.disabled ? TextStyle(color: ThemeColors.textDisabled) : null);
          switch (tab.badgeSource) {
            case BadgeSource.openInvitations:
              if (campaignValueStore.openInvitations > 0) {
                tabWidget = Badge(child: tabWidget);
              }
              break;
            case BadgeSource.none:
              break;
          }
          return Tab(child: tabWidget);
        }).toList(),
      ),
    );
  }

  void _onCampaignValueStoreChange() {
    setState(() {});
  }
}
