import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiDivisionsService extends GrueneApiBaseService {
  Future<List<Division>> searchDivision(String searchTerm) async => getFromApi(
    apiRequest: (api) => api.v1DivisionsGet(search: searchTerm),
    map: (result) => result.data,
  );

  Future<Division> getDivision(String divisionKey) async => getFromApi(
    apiRequest: (api) => api.v1DivisionsDivisionIdGet(divisionId: divisionKey),
    map: (result) => result,
  );
}
