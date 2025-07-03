import 'package:turf/transform.dart';

class MapLayerModel {
  final String id;
  final List<List<Position>> coords;
  final double score;
  final String? description;

  const MapLayerModel({required this.id, required this.coords, required this.score, required this.description});
}
