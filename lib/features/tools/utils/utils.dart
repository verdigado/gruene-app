import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension ToolsExtension on List<GnetzApplication> {
  List<GnetzApplicationCategory> get sortedCategories {
    final categories = map((tool) => tool.categories).expand((it) => it).toSet().toList();
    categories.sort((a, b) => a.order.compareTo(b.order));
    return categories;
  }
}
