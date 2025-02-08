import 'package:flutter/material.dart';
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

bool isCustomFilterSelected(
  List<Division> selectedDivisions,
  List<NewsCategory> selectedCategories,
  DateTimeRange? dateRange,
) =>
    !(selectedDivisions.length == 1 && selectedDivisions[0].level == DivisionLevel.bv) ||
    selectedCategories.isNotEmpty ||
    dateRange != null;

String getPlaceholderImage(String id) {
  return 'assets/graphics/placeholders/placeholder_${int.parse(id) % 3 + 1}.jpg';
}
