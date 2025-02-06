import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<List<GnetzApplication>> fetchTools() async => getFromApi(
      request: (api) => api.v1GnetzApplicationsGet(),
      map: (data) => data.data,
    );

List<GnetzApplicationCategory> getToolCategories(List<GnetzApplication> tools) {
  final categories = tools.map((tool) => tool.categories).expand((it) => it).toSet().toList();
  categories.sort((a, b) => a.order.compareTo(b.order));
  return categories;
}
