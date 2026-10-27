import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ExperienceAreasApiService extends BaseApiService {
  ExperienceAreasApiService() : super();

  Future<ExperienceArea> getExperienceArea(String experienceAreaId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsExperienceAreasExperienceAreaIdGet(experienceAreaId: experienceAreaId),
  );
}
