import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_statistics_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_model.dart';
import 'package:gruene_app/features/campaigns/screens/badge_statistics_detail.dart';
import 'package:gruene_app/features/campaigns/screens/poi_statistics_detail.dart';
import 'package:gruene_app/features/campaigns/screens/team_statistics_detail.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
            BadgeStatisticsDetail(poiStatistics: _poiStatistics),
            TeamStatisticsDetail(teamStatistics: _teamStatistics),
            PoiStatisticsDetail(poiStatistics: _poiStatistics, teamMembershipStatistics: _teamMembershipStatistics),
          ],
        ),
      ),
    );
  }

  Future<void> reload() async {
    _loadData();
  }

  void _loadData() async {
    setState(() => _loading = true);

    var results = await Future.wait([_loadPoiStatistics(), _loadTeamStatistics(), _loadOwnTeamStatistics()]);

    var poiCampaignStatistics = results[0] as CampaignStatisticsModel;
    var teamStatistics = results[1] as TeamStatistics;
    var teamMembershipStatistics = results[2] as TeamMembershipStatistics;

    setState(() {
      _loading = false;
      _poiStatistics = poiCampaignStatistics;
      _teamStatistics = teamStatistics;
      _teamMembershipStatistics = teamMembershipStatistics;
    });
  }

  Future<CampaignStatisticsModel> _loadPoiStatistics() async {
    var campaignSettings = GetIt.I<AppSettings>().campaign;

    if (campaignSettings.recentPoiStatistics != null &&
        DateTime.now().isBefore(campaignSettings.recentPoiStatisticsFetchTimestamp!.add(Duration(minutes: 5)))) {
      return campaignSettings.recentPoiStatistics!;
    }
    var statApiService = GetIt.I<GrueneApiCampaignsStatisticsService>();
    var campaignStatistics = await statApiService.getStatistics();

    campaignSettings.recentPoiStatistics = campaignStatistics;
    campaignSettings.recentPoiStatisticsFetchTimestamp = DateTime.now();

    return campaignStatistics;
  }

  Future<TeamStatistics> _loadTeamStatistics() async {
    var campaignSettings = GetIt.I<AppSettings>().campaign;

    if (campaignSettings.recentTeamStatistics != null &&
        DateTime.now().isBefore(campaignSettings.recentTeamStatisticsFetchTimestamp!.add(Duration(minutes: 5)))) {
      return campaignSettings.recentTeamStatistics!;
    }
    var teamApiService = GetIt.I<GrueneApiTeamsService>();
    var teamStats = await teamApiService.getTeamStatistics();

    campaignSettings.recentTeamStatistics = teamStats;
    campaignSettings.recentTeamStatisticsFetchTimestamp = DateTime.now();

    return teamStats;
  }

  Future<TeamMembershipStatistics> _loadOwnTeamStatistics() async {
    var campaignSettings = GetIt.I<AppSettings>().campaign;

    if (campaignSettings.recentTeamMembershipStatistics != null &&
        DateTime.now().isBefore(
          campaignSettings.recentTeamMembershipStatisticsFetchTimestamp!.add(Duration(minutes: 5)),
        )) {
      return campaignSettings.recentTeamMembershipStatistics!;
    }
    var teamApiService = GetIt.I<GrueneApiTeamsService>();

    try {
      var teamMembershipStats = await teamApiService.getTeamMembershipStatistics(onlyMyData: true);

      campaignSettings.recentTeamMembershipStatistics = teamMembershipStats;
      campaignSettings.recentTeamMembershipStatisticsFetchTimestamp = DateTime.now();

      return teamMembershipStats;
    } on ApiException catch (e) {
      logger.d(e.message);
      rethrow;
    }
  }
}
