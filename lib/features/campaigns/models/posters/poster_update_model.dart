import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_photo_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'poster_update_model.g.dart';

@JsonSerializable()
class PosterUpdateModel {
  final String id;
  final AddressModel address;
  final PosterStatus status;
  final String comment;
  @LatLongConverter()
  final LatLng location;
  final PosterDetailModel oldPosterDetail;
  final List<String> deletedPhotoIds;
  final List<PosterPhotoModel> newPhotos;

  PosterUpdateModel({
    required this.id,
    required this.address,
    required this.status,
    required this.comment,
    required this.location,
    required this.oldPosterDetail,
    required this.deletedPhotoIds,
    required this.newPhotos,
  });

  factory PosterUpdateModel.fromJson(Map<String, dynamic> json) => _$PosterUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$PosterUpdateModelToJson(this);

  PosterUpdateModel copyWith({
    String? id,
    AddressModel? address,
    PosterStatus? status,
    String? comment,
    LatLng? location,
    List<String>? deletedPhotoIds,
    List<PosterPhotoModel>? newPhotos,
    PosterDetailModel? oldPosterDetail,
  }) {
    return PosterUpdateModel(
      id: id ?? this.id,
      address: address ?? this.address,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      location: location ?? this.location,
      deletedPhotoIds: deletedPhotoIds ?? this.deletedPhotoIds,
      newPhotos: newPhotos ?? this.newPhotos,
      oldPosterDetail: oldPosterDetail ?? this.oldPosterDetail,
    );
  }
}
