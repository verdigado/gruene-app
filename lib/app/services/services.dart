import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_action_area_service.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_statistics_service.dart';
import 'package:gruene_app/app/services/gruene_api_challenge_service.dart';
import 'package:gruene_app/app/services/gruene_api_divisions_service.dart';
import 'package:gruene_app/app/services/gruene_api_door_service.dart';
import 'package:gruene_app/app/services/gruene_api_experience_area_service.dart';
import 'package:gruene_app/app/services/gruene_api_flyer_service.dart';
import 'package:gruene_app/app/services/gruene_api_poster_service.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/services/gruene_api_route_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/services/gruene_api_user_service.dart';
import 'package:gruene_app/app/services/gruene_api_visual_identifier_service.dart';

void initializeApiServices() {
  GetIt.I.registerFactory<GrueneApiPosterService>(() => GrueneApiPosterService());
  GetIt.I.registerFactory<GrueneApiDoorService>(() => GrueneApiDoorService());
  GetIt.I.registerFactory<GrueneApiFlyerService>(() => GrueneApiFlyerService());
  GetIt.I.registerFactory<GrueneApiRouteService>(() => GrueneApiRouteService());
  GetIt.I.registerFactory<GrueneApiActionAreaService>(() => GrueneApiActionAreaService());
  GetIt.I.registerFactory<GrueneApiExperienceAreaService>(() => GrueneApiExperienceAreaService());
  GetIt.I.registerFactory<GrueneApiCampaignsStatisticsService>(() => GrueneApiCampaignsStatisticsService());
  GetIt.I.registerFactory<GrueneApiCampaignService>(() => GrueneApiCampaignService());
  GetIt.I.registerFactory<GrueneApiTeamsService>(() => GrueneApiTeamsService());
  GetIt.I.registerFactory<GrueneApiDivisionsService>(() => GrueneApiDivisionsService());
  GetIt.I.registerFactory<GrueneApiProfileService>(() => GrueneApiProfileService());
  GetIt.I.registerFactory<GrueneApiUserService>(() => GrueneApiUserService());
  GetIt.I.registerFactory<GrueneApiChallengeService>(() => GrueneApiChallengeService());
  GetIt.I.registerFactory<GrueneApiVisualIdentifierService>(() => GrueneApiVisualIdentifierService());
}
