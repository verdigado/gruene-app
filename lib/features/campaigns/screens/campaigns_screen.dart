import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/screens/router_tab_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/tab_bar.dart';
import 'package:gruene_app/features/campaigns/widgets/refresh_button.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CampaignsScreen extends StatelessWidget {
  final List<RouterTabModel> campaignTabs = [
    RouterTabModel(
      label: t.campaigns.door.label,
      route: RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignDoorDetail]),
    ),
    RouterTabModel(
      label: t.campaigns.poster.label,
      route: RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignPosterDetail]),
    ),
    RouterTabModel(
      label: t.campaigns.flyer.label,
      route: RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignFlyerDetail]),
    ),
    RouterTabModel(
      label: t.campaigns.team.label,
      route: RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignTeamDetail]),
    ),
    RouterTabModel(
      label: t.campaigns.statistic.label,
      route: RouteLocations.getRoute([RouteLocations.campaigns, RouteLocations.campaignStatisticsDetail]),
    ),
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
