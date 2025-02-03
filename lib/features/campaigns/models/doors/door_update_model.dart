import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'door_update_model.g.dart';

@JsonSerializable()
class DoorUpdateModel {
  final int openedDoors;
  final int closedDoors;
  final String id;
  final AddressModel address;
  @LatLongConverter()
  final LatLng location;
  final DoorDetailModel oldDoorDetail;

  DoorUpdateModel({
    required this.id,
    required this.address,
    required this.openedDoors,
    required this.closedDoors,
    required this.oldDoorDetail,
    required this.location,
  });

  factory DoorUpdateModel.fromJson(Map<String, dynamic> json) => _$DoorUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$DoorUpdateModelToJson(this);
}
