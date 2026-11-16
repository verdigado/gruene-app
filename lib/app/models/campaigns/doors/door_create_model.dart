import 'package:gruene_app/app/models/campaigns/posters/poster_create_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'door_create_model.g.dart';

@JsonSerializable()
class DoorCreateModel {
  @LatLongConverter()
  final LatLng location;
  final AddressModel address;
  final int conversations;
  final int materialOnly;

  final String campaignId;

  DoorCreateModel({
    required this.location,
    required this.address,
    required this.conversations,
    required this.materialOnly,
    required this.campaignId,
  });

  factory DoorCreateModel.fromJson(Map<String, dynamic> json) => _$DoorCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$DoorCreateModelToJson(this);
}
