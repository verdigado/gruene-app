import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'flyer_create_model.g.dart';

@JsonSerializable()
class FlyerCreateModel {
  @LatLongConverter()
  final LatLng location;

  final AddressModel address;

  final int flyerCount;

  FlyerCreateModel({required this.location, required this.address, required this.flyerCount});

  factory FlyerCreateModel.fromJson(Map<String, dynamic> json) => _$FlyerCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$FlyerCreateModelToJson(this);
}
