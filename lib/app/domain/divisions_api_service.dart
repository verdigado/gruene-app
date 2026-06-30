import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<List<Division>> loadDivisions([List<String>? divisionKeys]) async => getFromApi(
  request: (api) => api.v1DivisionsGet(limit: 100000, divisionKey: divisionKeys),
  map: (data) => data.data,
);
