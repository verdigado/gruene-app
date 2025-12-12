import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiExperienceAreaService extends GrueneApiBaseService {
  GrueneApiExperienceAreaService() : super();

  Future<ExperienceArea> getExperienceArea(String experienceAreaId) async => getFromApi(
    apiRequest: (api) => api.v1CampaignsExperienceAreasExperienceAreaIdGet(experienceAreaId: experienceAreaId),
  );
}
