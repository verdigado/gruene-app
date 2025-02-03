import 'dart:typed_data';

import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'poster_create_model.g.dart';

@JsonSerializable()
class PosterCreateModel {
  AddressModel address;

  @LatLongConverter()
  final LatLng location;

  final String? imageFileLocation;

  PosterCreateModel({
    required this.address,
    this.imageFileLocation,
    required this.location,
  });

  factory PosterCreateModel.fromJson(Map<String, dynamic> json) => _$PosterCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$PosterCreateModelToJson(this);
}

/// Converts to and from [Uint8List] and [List]<[int]>.
class Uint8ListConverter implements JsonConverter<Uint8List?, List<int>?> {
  /// Create a new instance of [Uint8ListConverter].
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(List<int>? json) {
    if (json == null) return null;

    return Uint8List.fromList(json);
  }

  @override
  List<int>? toJson(Uint8List? object) {
    if (object == null) return null;

    return object.toList();
  }
}

class LatLongConverter implements JsonConverter<LatLng, List<double>> {
  /// Create a new instance of [LatLongConverter].
  const LatLongConverter();

  @override
  LatLng fromJson(List<double> json) {
    return LatLng(json[0], json[1]);
  }

  @override
  List<double> toJson(LatLng object) {
    return [object.latitude, object.longitude];
  }
}
