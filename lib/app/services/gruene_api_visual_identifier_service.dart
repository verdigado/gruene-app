import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiVisualIdentifierService extends GrueneApiBaseService {
  GrueneApiVisualIdentifierService() : super();

  Future<List<VisualIdentifier>> getVisualIdentifiers() =>
      getFromApi(apiRequest: (api) => api.v1CampaignsVisualIdentifiersGet(), map: (result) => result.data);
}
