import 'package:gruene_app/app/services/nominatim_service.dart';
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
}
