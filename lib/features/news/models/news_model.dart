import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewsModel {
  String id;
  String title;
  String summary;
  String content;
  String? author;
  ImageSrcSet? image;
  String type;
  Division? division;
  List<NewsCategory> categories;
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
      author: null,
      image: news.featuredImage,
      type: news.categories.firstOrNull?.label ?? '',
      division: division,
      categories: news.categories,
      createdAt: news.createdAt,
      bookmarked: false,
    );
  }
}

extension Filter on List<NewsModel> {
  List<NewsModel> filter(
    List<Division> divisions,
    List<NewsCategory> categories,
    bool bookmarked,
    DateTimeRange? dateRange,
  ) {
    return where(
      (it) =>
          (divisions.isEmpty || divisions.contains(it.division)) &&
          (categories.isEmpty || categories.containsAny(it.categories)) &&
          (!bookmarked || it.bookmarked) &&
          (dateRange == null || it.createdAt.isBetween(dateRange)),
    ).toList();
  }
}
