// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'door_detail_model.g.dart';

@JsonSerializable()
class DoorDetailModel {
  String id;

  final AddressModel address;
  final int openedDoors;
  final int closedDoors;
  final String createdAt;
  @LatLongConverter()
  final LatLng location;
  final bool isCached;

  DoorDetailModel({
    required this.id,
    required this.address,
    required this.openedDoors,
    required this.closedDoors,
    required this.createdAt,
    required this.location,
    this.isCached = false,
  });

  factory DoorDetailModel.fromJson(Map<String, dynamic> json) => _$DoorDetailModelFromJson(json.convertLatLongField());

  Map<String, dynamic> toJson() => _$DoorDetailModelToJson(this);

  DoorDetailModel copyWith({
    String? id,
    AddressModel? address,
    int? openedDoors,
    int? closedDoors,
    String? createdAt,
    LatLng? location,
    bool? isCached,
  }) {
    return DoorDetailModel(
      id: id ?? this.id,
      address: address ?? this.address,
      openedDoors: openedDoors ?? this.openedDoors,
      closedDoors: closedDoors ?? this.closedDoors,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      isCached: isCached ?? this.isCached,
    );
  }
}
