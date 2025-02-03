import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'door_create_model.g.dart';

@JsonSerializable()
class DoorCreateModel {
  @LatLongConverter()
  final LatLng location;
  final AddressModel address;
  final int openedDoors;
  final int closedDoors;

  DoorCreateModel({
    required this.location,
    required this.address,
    required this.openedDoors,
    required this.closedDoors,
  });

  factory DoorCreateModel.fromJson(Map<String, dynamic> json) => _$DoorCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$DoorCreateModelToJson(this);
}
