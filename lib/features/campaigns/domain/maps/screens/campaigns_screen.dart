import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/enums/badge_source.dart';
import 'package:gruene_app/app/screens/router_tab_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/tab_bar.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/campaign_select_button.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/refresh_button.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/campaign_select_dialog.dart';
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CampaignsScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  final List<Widget> children;

  const CampaignsScreen({super.key, required this.navigationShell, required this.children});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  final _activeCampaignNotifier = GetIt.I<ActiveCampaignNotifier>();

  final List<TabModelBase> campaignTabs = [
    TabModelBase(label: t.campaigns.door.label),
    TabModelBase(label: t.campaigns.poster.label),
    TabModelBase(label: t.campaigns.stand.label),
    TabModelBase(label: t.campaigns.challenges.label),
    TabModelBase(label: t.campaigns.team.label, badgeSource: BadgeSource.openInvitations),
    TabModelBase(label: t.campaigns.statistics.label),
  ];

  @override
  void initState() {
    super.initState();
    // added once and removed on dispose: the notifier outlives this screen
    _activeCampaignNotifier.addListener(_onActiveCampaignChanged);
  }

  @override
  void dispose() {
    _activeCampaignNotifier.removeListener(_onActiveCampaignChanged);
    super.dispose();
  }

  void _onActiveCampaignChanged() {
    if (!mounted) return;
    showCampaignSelectDialog(context, enforceSelect: true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_activeCampaignNotifier.isCurrentCampaignActive) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showCampaignSelectDialog(context, enforceSelect: true);
      });
    }

    return RouterTabScreen(
      appBarBuilder: (PreferredSizeWidget tabBar) => MainAppBar(
        title: t.campaigns.title,
        appBarAction: RefreshButton(),
        tabBar: tabBar,
        leadingAction: CampaignSelectButton(),
      ),
      tabs: campaignTabs,
      scrollableBody: false,
      navigationShell: widget.navigationShell,
      children: widget.children,
    );
  }
}
