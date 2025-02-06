import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<Profile> fetchOwnProfile() async => getFromApi(request: (api) => api.v1ProfilesSelfGet(), map: (data) => data);
