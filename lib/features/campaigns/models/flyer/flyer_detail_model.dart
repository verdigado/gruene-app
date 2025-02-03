// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'flyer_detail_model.g.dart';

@JsonSerializable()
class FlyerDetailModel {
  final String id;
  final AddressModel address;
  final int flyerCount;
  final String createdAt;
  final bool isCached;

  @LatLongConverter()
  final LatLng location;

  FlyerDetailModel({
    required this.id,
    required this.address,
    required this.flyerCount,
    required this.createdAt,
    required this.location,
    this.isCached = false,
  });

  factory FlyerDetailModel.fromJson(Map<String, dynamic> json) =>
      _$FlyerDetailModelFromJson(json.convertLatLongField());

  Map<String, dynamic> toJson() => _$FlyerDetailModelToJson(this);

  FlyerDetailModel copyWith({
    String? id,
    AddressModel? address,
    int? flyerCount,
    String? createdAt,
    bool? isCached,
    LatLng? location,
  }) {
    return FlyerDetailModel(
      id: id ?? this.id,
      address: address ?? this.address,
      flyerCount: flyerCount ?? this.flyerCount,
      createdAt: createdAt ?? this.createdAt,
      isCached: isCached ?? this.isCached,
      location: location ?? this.location,
    );
  }
}
