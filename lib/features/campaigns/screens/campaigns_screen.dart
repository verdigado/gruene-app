import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/tab_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/tab_bar.dart';
import 'package:gruene_app/features/campaigns/screens/doors_screen.dart';
import 'package:gruene_app/features/campaigns/screens/flyer_screen.dart';
import 'package:gruene_app/features/campaigns/screens/posters_screen.dart';
import 'package:gruene_app/features/campaigns/screens/statistics_screen.dart';
import 'package:gruene_app/features/campaigns/screens/teams_screen.dart';
import 'package:gruene_app/features/campaigns/widgets/refresh_button.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CampaignsScreen extends StatelessWidget {
  final List<TabModel> campaignTabs = [
    TabModel(label: t.campaigns.door.label, view: DoorsScreen()),
    TabModel(label: t.campaigns.poster.label, view: PostersScreen()),
    TabModel(label: t.campaigns.flyer.label, view: FlyerScreen()),
    TabModel(label: t.campaigns.team.label, view: TeamsScreen(), disabled: true),
    TabModel(label: t.campaigns.statistic.label, view: StatisticsScreen()),
  ];

  CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScreen(
      appBarBuilder: (PreferredSizeWidget tabBar) => MainAppBar(
        title: t.campaigns.campaigns,
        appBarAction: RefreshButton(),
        tabBar: tabBar,
      ),
      tabs: campaignTabs,
      scrollableBody: false,
    );
  }
}
