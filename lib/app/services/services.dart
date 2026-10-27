import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/action_area_api_service.dart';
import 'package:gruene_app/app/services/api/campaign_api_service.dart';
import 'package:gruene_app/app/services/api/campaigns_statistics_api_service.dart';
import 'package:gruene_app/app/services/api/challenge_api_service.dart';
import 'package:gruene_app/app/services/api/division_api_service.dart';
import 'package:gruene_app/app/services/api/door_api_service.dart';
import 'package:gruene_app/app/services/api/experience_area_api_service.dart';
import 'package:gruene_app/app/services/api/flyer_api_service.dart';
import 'package:gruene_app/app/services/api/poster_api_service.dart';
import 'package:gruene_app/app/services/api/profile_api_service.dart';
import 'package:gruene_app/app/services/api/route_api_service.dart';
import 'package:gruene_app/app/services/api/teams_api_service.dart';
import 'package:gruene_app/app/services/api/user_api_service.dart';
import 'package:gruene_app/app/services/api/visual_identifier_api_service.dart';
import 'package:gruene_app/features/events/services/event_api_service.dart';
import 'package:gruene_app/features/news/services/news_api_service.dart';
import 'package:gruene_app/features/tools/services/tool_api_service.dart';

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
  GetIt.I.registerFactory(CampaignsStatisticsApiService.new);
  GetIt.I.registerFactory(CampaignApiService.new);
  GetIt.I.registerFactory(TeamsApiService.new);
  GetIt.I.registerFactory(UserApiService.new);
  GetIt.I.registerFactory(ChallengeApiService.new);
  GetIt.I.registerFactory(VisualIdentifierApiService.new);
}
