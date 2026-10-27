import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class DivisionsApiService extends BaseApiService {
  Future<List<Division>> searchDivision({
    String? searchTerm,
    int? offset,
    int? limit,
    List<String>? divisionKeys,
    HierarchyLevel? level,
  }) async => send(
    request: (api) =>
        api.v1DivisionsGet(search: searchTerm, offset: offset, limit: limit, divisionKey: divisionKeys, level: level),
    map: (result) => result.data,
  );

  Future<List<Division>> loadDivisions([List<String>? divisionKeys]) async => send(
    request: (api) => api.v1DivisionsGet(limit: 100000, divisionKey: divisionKeys),
    map: (result) => result.data,
  );
}
