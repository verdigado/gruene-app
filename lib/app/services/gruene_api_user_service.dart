import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/app/utils/globals.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiUserService extends GrueneApiBaseService {
  Future<User> getSelf() async => getFromApi(apiRequest: (api) => api.v1UsersSelfGet(), map: id);
}
