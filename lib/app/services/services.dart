import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/action_areas_api_service.dart';
import 'package:gruene_app/app/services/api/campaigns_api_service.dart';
import 'package:gruene_app/app/services/api/campaigns_statistics_api_service.dart';
import 'package:gruene_app/app/services/api/challenges_api_service.dart';
import 'package:gruene_app/app/services/api/divisions_api_service.dart';
import 'package:gruene_app/app/services/api/doors_api_service.dart';
import 'package:gruene_app/app/services/api/experience_areas_api_service.dart';
import 'package:gruene_app/app/services/api/flyers_api_service.dart';
import 'package:gruene_app/app/services/api/posters_api_service.dart';
import 'package:gruene_app/app/services/api/profiles_api_service.dart';
import 'package:gruene_app/app/services/api/routes_api_service.dart';
import 'package:gruene_app/app/services/api/teams_api_service.dart';
import 'package:gruene_app/app/services/api/users_api_service.dart';
import 'package:gruene_app/app/services/api/visual_identifiers_api_service.dart';

void initializeApiServices() {
  GetIt.I.registerFactory(PostersApiService.new);
  GetIt.I.registerFactory(DoorsApiService.new);
  GetIt.I.registerFactory(FlyersApiService.new);
  GetIt.I.registerFactory(RoutesApiService.new);
  GetIt.I.registerFactory(ActionAreasApiService.new);
  GetIt.I.registerFactory(ExperienceAreasApiService.new);
  GetIt.I.registerFactory(CampaignsStatisticsApiService.new);
  GetIt.I.registerFactory(CampaignsApiService.new);
  GetIt.I.registerFactory(TeamsApiService.new);
  GetIt.I.registerFactory(DivisionsApiService.new);
  GetIt.I.registerFactory(ProfilesApiService.new);
  GetIt.I.registerFactory(UsersApiService.new);
  GetIt.I.registerFactory(ChallengesApiService.new);
  GetIt.I.registerFactory(VisualIdentifiersApiService.new);
}
