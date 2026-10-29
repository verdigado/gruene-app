import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/action_area_api_service.dart';
import 'package:gruene_app/app/services/api/campaign_api_service.dart';
import 'package:gruene_app/app/services/api/campaign_statistic_api_service.dart';
import 'package:gruene_app/app/services/api/challenge_api_service.dart';
import 'package:gruene_app/app/services/api/client/news_api_service.dart';
import 'package:gruene_app/app/services/api/division_api_service.dart';
import 'package:gruene_app/app/services/api/door_api_service.dart';
import 'package:gruene_app/app/services/api/event_api_service.dart';
import 'package:gruene_app/app/services/api/experience_area_api_service.dart';
import 'package:gruene_app/app/services/api/flyer_api_service.dart';
import 'package:gruene_app/app/services/api/poster_api_service.dart';
import 'package:gruene_app/app/services/api/profile_api_service.dart';
import 'package:gruene_app/app/services/api/route_api_service.dart';
import 'package:gruene_app/app/services/api/team_api_service.dart';
import 'package:gruene_app/app/services/api/tool_api_service.dart';
import 'package:gruene_app/app/services/api/user_api_service.dart';
import 'package:gruene_app/app/services/api/visual_identifier_api_service.dart';

void initializeApiServices() {
  GetIt.I.registerFactory(DivisionApiService.new);
  GetIt.I.registerFactory(ProfileApiService.new);
  GetIt.I.registerFactory(EventApiService.new);
  GetIt.I.registerFactory(NewsApiService.new);
  GetIt.I.registerFactory(ToolApiService.new);
  GetIt.I.registerFactory(PosterApiService.new);
  GetIt.I.registerFactory(DoorApiService.new);
  GetIt.I.registerFactory(FlyerApiService.new);
  GetIt.I.registerFactory(RouteApiService.new);
  GetIt.I.registerFactory(ActionAreaApiService.new);
  GetIt.I.registerFactory(ExperienceAreaApiService.new);
  GetIt.I.registerFactory(CampaignStatisticApiService.new);
  GetIt.I.registerFactory(CampaignApiService.new);
  GetIt.I.registerFactory(TeamApiService.new);
  GetIt.I.registerFactory(UserApiService.new);
  GetIt.I.registerFactory(ChallengeApiService.new);
  GetIt.I.registerFactory(VisualIdentifierApiService.new);
}
