import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ExperienceAreaApiService extends BaseApiService {
  ExperienceAreaApiService() : super();

  Future<ExperienceArea> getExperienceArea(String experienceAreaId) async =>
      send(request: (api) => api.v1CampaignsExperienceAreasExperienceAreaIdGet(experienceAreaId: experienceAreaId));
}
