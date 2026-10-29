import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ToolApiService extends BaseApiService {
  Future<List<GnetzApplication>> getTools() async =>
      send(request: (api) => api.v1GnetzApplicationsGet(), map: (data) => data.data);
}
