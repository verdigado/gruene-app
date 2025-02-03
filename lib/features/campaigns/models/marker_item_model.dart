import 'package:maplibre_gl/maplibre_gl.dart';

class MarkerItemModel {
  final LatLng location;
  final int? id;
  final String? status;
  final bool isVirtual;

  const MarkerItemModel({
    required this.id,
    required this.status,
    required this.location,
  }) : isVirtual = false;

  MarkerItemModel.virtual({
    required this.id,
    this.status,
    required this.location,
  }) : isVirtual = true;
}
