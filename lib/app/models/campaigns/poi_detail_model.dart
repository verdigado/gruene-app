import 'package:maplibre_gl/maplibre_gl.dart';

class PoiDetailModel {
  final LatLng location;
  final int? id;
  final String? status;
  final bool isVirtual;

  const PoiDetailModel({required this.id, required this.status, required this.location}) : isVirtual = false;

  PoiDetailModel.virtual({required this.id, this.status, required this.location}) : isVirtual = true;
}
