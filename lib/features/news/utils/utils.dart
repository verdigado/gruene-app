import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension NewsListExtension on List<NewsModel> {
  List<Division> divisions() => map((it) => it.division).nonNulls.toSet().toList();

  List<NewsCategory> categories() {
    final categories = map((it) => it.categories).expand((it) => it).nonNulls.toSet().toList();
    categories.sort((a, b) => a.label.compareTo(b.label));
    return categories;
  }
}

extension ImageVariant on ImageSrcSet {
  Image variant(String type) => srcset.firstWhereOrNull((image) => image.type == type) ?? original;
}
