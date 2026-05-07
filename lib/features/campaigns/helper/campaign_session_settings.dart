// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/helper/active_campaign_settings.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class CampaignSessionSettings {
  LatLng? lastPosition;
  double? lastZoomLevel;

  bool imageConsentConfirmed = false;

  String? searchString;
  List<SearchResultItem>? searchResult = [];

  CampaignStatisticsModel? recentPoiStatistics;
  DateTime? recentPoiStatisticsFetchTimestamp;

  TeamStatistics? recentTeamStatistics;
  DateTime? recentTeamStatisticsFetchTimestamp;

  TeamMembershipStatistics? recentTeamMembershipStatistics;
  DateTime? recentTeamMembershipStatisticsFetchTimestamp;

  late ActiveCampaignSettings _activeCampaignSettings;

  ActiveCampaignSettings get activeCampaign => _activeCampaignSettings;

  Future<void> init() async {
    _activeCampaignSettings = await ActiveCampaignSettings.restore();
  }
}
