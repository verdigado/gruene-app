import 'package:gruene_app/app/models/campaigns/posters/poster_create_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_photo_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'stand_update_model.g.dart';

/// Changes to the stand itself. Termine are changed through their own calls.
@JsonSerializable()
class StandUpdateModel {
  final String id;
  final AddressModel address;
  @LatLongConverter()
  final LatLng location;
  final String name;
  final String? description;
  final String? comment;
  final StandDetailModel oldStandDetail;
  final List<String> deletedPhotoIds;

  /// New photos; their [PosterPhotoModel.imageUrl] is the local file to upload.
  final List<PosterPhotoModel> newPhotos;

  StandUpdateModel({
    required this.id,
    required this.address,
    required this.location,
    required this.name,
    this.description,
    this.comment,
    required this.oldStandDetail,
    this.deletedPhotoIds = const [],
    this.newPhotos = const [],
  });

  factory StandUpdateModel.fromJson(Map<String, dynamic> json) => _$StandUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$StandUpdateModelToJson(this);
}
