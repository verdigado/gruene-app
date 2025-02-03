import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'poster_update_model.g.dart';

@JsonSerializable()
class PosterUpdateModel {
  final String id;
  final AddressModel address;
  final PosterStatus status;
  final String comment;
  final String? newImageFileLocation;
  @LatLongConverter()
  final LatLng location;
  final bool removePreviousPhotos;
  final PosterDetailModel oldPosterDetail;

  PosterUpdateModel({
    required this.id,
    required this.address,
    required this.status,
    required this.comment,
    required this.removePreviousPhotos,
    required this.location,
    this.newImageFileLocation,
    required this.oldPosterDetail,
  });

  factory PosterUpdateModel.fromJson(Map<String, dynamic> json) => _$PosterUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$PosterUpdateModelToJson(this);

  PosterUpdateModel copyWith({
    String? id,
    AddressModel? address,
    PosterStatus? status,
    String? comment,
    String? newImageFileLocation,
    LatLng? location,
    bool? removePreviousPhotos,
    PosterDetailModel? oldPosterDetail,
  }) {
    return PosterUpdateModel(
      id: id ?? this.id,
      address: address ?? this.address,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      newImageFileLocation: newImageFileLocation ?? this.newImageFileLocation,
      location: location ?? this.location,
      removePreviousPhotos: removePreviousPhotos ?? this.removePreviousPhotos,
      oldPosterDetail: oldPosterDetail ?? this.oldPosterDetail,
    );
  }
}
