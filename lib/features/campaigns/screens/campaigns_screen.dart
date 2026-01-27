import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/screens/router_tab_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/tab_bar.dart';
import 'package:gruene_app/features/campaigns/widgets/refresh_button.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CampaignsScreen extends StatelessWidget {
  final List<TabModelBase> campaignTabs = [
    TabModelBase(label: t.campaigns.door.label),
    TabModelBase(label: t.campaigns.poster.label),
    TabModelBase(label: t.campaigns.flyer.label),
    TabModelBase(label: t.campaigns.team.label),
    TabModelBase(label: t.campaigns.statistic.label),
  ];

  final StatefulNavigationShell navigationShell;

  final List<Widget> children;

  CampaignsScreen({super.key, required this.navigationShell, required this.children});

  @override
  Widget build(BuildContext context) {
    return RouterTabScreen(
      appBarBuilder: (PreferredSizeWidget tabBar) =>
          MainAppBar(title: t.campaigns.campaigns, appBarAction: RefreshButton(), tabBar: tabBar),
      tabs: campaignTabs,
      scrollableBody: false,
      navigationShell: navigationShell,
      children: children,
    );
  }
}
