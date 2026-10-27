import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class VisualIdentifiersApiService extends BaseApiService {
  VisualIdentifiersApiService() : super();

  Future<List<VisualIdentifier>> getVisualIdentifiers() =>
      getFromApi(request: (api) => api.v1CampaignsVisualIdentifiersGet(), map: (result) => result.data);
}
