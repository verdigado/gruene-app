import 'package:get_it/get_it.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<NewsModel?> fetchNewsById(String newsId) async {
  final GrueneApi api = GetIt.I<GrueneApi>();

  final response = await api.v1NewsNewsIdGet(newsId: newsId);
  if (!response.isSuccessful) {
    throw Exception('Fehler beim Laden des Artikels (Status Code: ${response.statusCode})');
  }

  return NewsModel.fromApi(response.body!);
}

Future<List<NewsModel>> fetchNews() async {
  final GrueneApi api = GetIt.I<GrueneApi>();

  final response = await api.v1NewsGet();
  if (!response.isSuccessful) {
    throw Exception('Fehler beim Laden der Artikel (${response.statusCode})');
  }
  return response.body!.data.map(NewsModel.fromApi).toList();
}
