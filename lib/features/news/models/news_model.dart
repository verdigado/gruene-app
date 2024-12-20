import 'package:gruene_app/app/models/division_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewsModel {
  String id;
  String title;
  String summary;
  String content;
  String author;
  String image;
  String type;
  DivisionModel? division;
  List<String> categories;
  DateTime createdAt;
  bool bookmarked;

  NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.author,
    required this.image,
    required this.type,
    required this.division,
    required this.categories,
    required this.createdAt,
    required this.bookmarked,
  });

  static NewsModel fromApi(News news) {
    final division = news.division;
    return NewsModel(
      id: news.id,
      title: news.title,
      summary: news.summary ?? 'Leere Zusammenfassung.',
      content: news.body.content,
      author: 'Peter Platzhalter',
      // TODO: Use placeholder as long as drupal blocks image access
      // image: news.featuredImage?.original.url ?? 'assets/graphics/placeholders/placeholder_1.jpg',
      image: 'assets/graphics/placeholders/placeholder_${int.parse(news.id) % 3 + 1}.jpg',
      type: news.categories.firstOrNull?.label ?? '',
      division: division != null ? DivisionModel.fromApi(division) : null,
      categories: news.categories.map((category) => category.label).toList(),
      createdAt: news.createdAt,
      bookmarked: false,
    );
  }
}
