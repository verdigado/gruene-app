import 'package:gruene_app/app/models/campaigns/flyer/flyer_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_create_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'flyer_update_model.g.dart';

@JsonSerializable()
class FlyerUpdateModel {
  final String id;
  final AddressModel address;
  final int flyerCount;
  @LatLongConverter()
  final LatLng location;
  final FlyerDetailModel oldFlyerDetail;

  FlyerUpdateModel({
    required this.id,
    required this.address,
    required this.flyerCount,
    required this.location,
    required this.oldFlyerDetail,
  });

  factory FlyerUpdateModel.fromJson(Map<String, dynamic> json) => _$FlyerUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$FlyerUpdateModelToJson(this);
}
