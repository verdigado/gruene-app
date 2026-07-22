import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_statistics_service.dart';
import 'package:gruene_app/app/services/gruene_api_challenge_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_model.dart';
import 'package:gruene_app/features/campaigns/screens/badge_statistics_detail.dart';
import 'package:gruene_app/features/campaigns/screens/challenge_badge_statistics_detail.dart';
import 'package:gruene_app/features/campaigns/screens/poi_statistics_detail.dart';
import 'package:gruene_app/features/campaigns/screens/team_statistics_detail.dart';
import 'package:gruene_app/features/campaigns/widgets/statistics_campaign_switcher.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _loading = true;
  late CampaignStatisticsModel _poiStatistics;
  late TeamStatistics _teamStatistics;
  late TeamMembershipStatistics _teamMembershipStatistics;
  late List<JoinedChallenge> _challengeBadges;
  final _appSettings = GetIt.I<AppSettings>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    _appSettings.campaign.activeCampaign.addListener(reload);
  }

  @override
  void dispose() {
    super.dispose();
    _appSettings.campaign.activeCampaign.removeListener(reload);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Container(alignment: Alignment.center, child: CircularProgressIndicator()),
      );
    }

    return RefreshIndicator(
      color: ThemeColors.primary,
      backgroundColor: ThemeColors.sun,
      onRefresh: () {
        return Future.delayed(Duration.zero, reload);
      },

      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            StatisticsCampaignSwitcher(campaignChanged: () => reload(overrideCache: true)),
            BadgeStatisticsDetail(poiStatistics: _poiStatistics),
            ChallengeBadgeStatisticsDetail(challengeBadges: _challengeBadges),
            TeamStatisticsDetail(teamStatistics: _teamStatistics),
            PoiStatisticsDetail(poiStatistics: _poiStatistics, teamMembershipStatistics: _teamMembershipStatistics),
          ],
        ),
      ),
    );
  }

  Future<void> reload({bool overrideCache = false}) async {
    _loadData(overrideCache: overrideCache);
  }

  void _loadData({bool overrideCache = false}) async {
    setState(() => _loading = true);

    var results = await Future.wait([
      _loadPoiStatistics(overrideCache: overrideCache),
      _loadTeamStatistics(overrideCache: overrideCache),
      _loadOwnTeamStatistics(overrideCache: overrideCache),
      _loadChallengeBadges(overrideCache: overrideCache),
    ]);

    var poiCampaignStatistics = results[0] as CampaignStatisticsModel;
    var teamStatistics = results[1] as TeamStatistics;
    var teamMembershipStatistics = results[2] as TeamMembershipStatistics;
    var challengeBadges = results[3] as List<JoinedChallenge>;

    setState(() {
      _loading = false;
      _poiStatistics = poiCampaignStatistics;
      _teamStatistics = teamStatistics;
      _teamMembershipStatistics = teamMembershipStatistics;
      _challengeBadges = challengeBadges;
    });
  }

  Future<CampaignStatisticsModel> _loadPoiStatistics({required bool overrideCache}) async {
    var campaignSettings = GetIt.I<AppSettings>().campaign;

    if (!overrideCache &&
        (campaignSettings.recentPoiStatistics != null &&
            DateTime.now().isBefore(campaignSettings.recentPoiStatisticsFetchTimestamp!.add(Duration(minutes: 5))))) {
      return campaignSettings.recentPoiStatistics!;
    }
    var statApiService = GetIt.I<GrueneApiCampaignsStatisticsService>();
    var currentPoiStatisticsCampaignId = getCurrentPoiStatisticsCampaignId();
    var campaignStatistics = await statApiService.getStatistics(
      campaigndId: currentPoiStatisticsCampaignId == '-1' ? null : currentPoiStatisticsCampaignId,
    );

    campaignSettings.recentPoiStatistics = campaignStatistics;
    campaignSettings.recentPoiStatisticsFetchTimestamp = DateTime.now();

    return campaignStatistics;
  }

  Future<TeamStatistics> _loadTeamStatistics({required bool overrideCache}) async {
    var campaignSettings = GetIt.I<AppSettings>().campaign;

    if (!overrideCache &&
        (campaignSettings.recentTeamStatistics != null &&
            DateTime.now().isBefore(campaignSettings.recentTeamStatisticsFetchTimestamp!.add(Duration(minutes: 5))))) {
      return campaignSettings.recentTeamStatistics!;
    }
    var teamApiService = GetIt.I<GrueneApiTeamsService>();
    var currentPoiStatisticsCampaignId = getCurrentPoiStatisticsCampaignId();
    var teamStats = await teamApiService.getTeamStatistics(
      campaignId: currentPoiStatisticsCampaignId == '-1' ? null : currentPoiStatisticsCampaignId,
    );

    campaignSettings.recentTeamStatistics = teamStats;
    campaignSettings.recentTeamStatisticsFetchTimestamp = DateTime.now();

    return teamStats;
  }

  Future<TeamMembershipStatistics> _loadOwnTeamStatistics({required bool overrideCache}) async {
    var campaignSettings = GetIt.I<AppSettings>().campaign;

    if (!overrideCache &&
        (campaignSettings.recentTeamMembershipStatistics != null &&
            DateTime.now().isBefore(
              campaignSettings.recentTeamMembershipStatisticsFetchTimestamp!.add(Duration(minutes: 5)),
            ))) {
      return campaignSettings.recentTeamMembershipStatistics!;
    }
    var teamApiService = GetIt.I<GrueneApiTeamsService>();

    try {
      var currentPoiStatisticsCampaignId = getCurrentPoiStatisticsCampaignId();
      var teamMembershipStats = await teamApiService.getTeamMembershipStatistics(
        campaignId: currentPoiStatisticsCampaignId == '-1' ? null : currentPoiStatisticsCampaignId,
      );

      campaignSettings.recentTeamMembershipStatistics = teamMembershipStats;
      campaignSettings.recentTeamMembershipStatisticsFetchTimestamp = DateTime.now();

      return teamMembershipStats;
    } on ApiException catch (e) {
      logger.d(e.message);
      rethrow;
    }
  }

  Future<List<JoinedChallenge>> _loadChallengeBadges({required bool overrideCache}) async {
    var campaignSettings = GetIt.I<AppSettings>().campaign;

    if (!overrideCache &&
        (campaignSettings.recentChallengeBadges != null &&
            DateTime.now().isBefore(campaignSettings.recentChallengeBadgesFetchTimestamp!.add(Duration(minutes: 5))))) {
      return campaignSettings.recentChallengeBadges!;
    }
    var challengeApiService = GetIt.I<GrueneApiChallengeService>();
    var currentPoiStatisticsCampaignId = getCurrentPoiStatisticsCampaignId();
    var challengeBadges = (await challengeApiService.getMyChallenges(
      campaignId: currentPoiStatisticsCampaignId == '-1' ? null : currentPoiStatisticsCampaignId,
      onlyCompleted: true,
      sorting: .endDescending,
    ));

    campaignSettings.recentChallengeBadges = challengeBadges;
    campaignSettings.recentChallengeBadgesFetchTimestamp = DateTime.now();

    return challengeBadges;
  }
}
