import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiDivisionsService extends GrueneApiBaseService {
  Future<List<Division>> searchDivision({
    String? searchTerm,
    int? offset,
    int? limit,
    List<String>? divisionKeys,
    DivisionLevel? level,
  }) async => getFromApi(
    apiRequest: (api) => api.v1DivisionsGet(
      search: searchTerm,
      offset: offset,
      limit: limit,
      divisionKey: divisionKeys,
      level: level?.asV1DivisionsGetLevel(),
    ),
    map: (result) => result.data,
  );
}
