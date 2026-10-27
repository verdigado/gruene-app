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
  GetIt.I.registerFactory(GrueneApiPosterService.new);
  GetIt.I.registerFactory(GrueneApiDoorService.new);
  GetIt.I.registerFactory(GrueneApiFlyerService.new);
  GetIt.I.registerFactory(GrueneApiRouteService.new);
  GetIt.I.registerFactory(GrueneApiActionAreaService.new);
  GetIt.I.registerFactory(GrueneApiExperienceAreaService.new);
  GetIt.I.registerFactory(GrueneApiCampaignsStatisticsService.new);
  GetIt.I.registerFactory(GrueneApiCampaignService.new);
  GetIt.I.registerFactory(GrueneApiTeamsService.new);
  GetIt.I.registerFactory(GrueneApiDivisionsService.new);
  GetIt.I.registerFactory(GrueneApiProfileService.new);
  GetIt.I.registerFactory(GrueneApiUserService.new);
  GetIt.I.registerFactory(GrueneApiChallengeService.new);
  GetIt.I.registerFactory(GrueneApiVisualIdentifierService.new);
}
