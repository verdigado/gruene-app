import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class DivisionApiService extends BaseApiService {
  Future<List<Division>> getDivisions({
    String? search,
    int? offset,
    int? limit,
    List<String>? divisionKeys,
    HierarchyLevel? level,
  }) async => send(
    request: (api) =>
        api.v1DivisionsGet(search: search, offset: offset, limit: limit, divisionKey: divisionKeys, level: level),
    map: (result) => result.data,
  );

  Future<List<Division>> getAllDivisions() async => getDivisions(limit: 100000);
}
