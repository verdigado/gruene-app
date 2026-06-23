import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

// TODO Temporary workaround for the categories prominently highlighted in the filter dialog
// The categories are Bundesvorstand, Digitalisierung and Wahlen & Wahlkampf
const prominentCategoryIds = ['2680259', '88764', '653'];

extension NewsListExtension on List<NewsModel> {
  List<NewsCategory> categories() {
    final categories = map((it) => it.categories).expand((it) => it).nonNulls.toSet().toList();
    categories.sort((a, b) {
      if (prominentCategoryIds.contains(a.id) && !prominentCategoryIds.contains(b.id)) {
        return -1;
      }
      if (prominentCategoryIds.contains(b.id) && !prominentCategoryIds.contains(a.id)) {
        return 1;
      }
      return a.label.compareTo(b.label);
    });
    return categories;
  }
}

extension ImageVariant on ImageSrcSet {
  Image variant(String type) => srcset.firstWhereOrNull((image) => image.type == type) ?? original;
}
