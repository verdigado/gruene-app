import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_create_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'poster_detail_model.g.dart';

enum PosterStatus {
  @JsonValue(100)
  ok,
  @JsonValue(200)
  damaged,
  @JsonValue(300)
  missing,
  @JsonValue(400)
  removed,
}

@JsonSerializable()
class PosterDetailModel {
  String id;
  String? thumbnailUrl;
  String? imageUrl;

  final AddressModel address;
  final String comment;
  final PosterStatus status;
  final String createdAt;
  final bool isCached;
  @LatLongConverter()
  final LatLng location;

  PosterDetailModel({
    required this.id,
    required this.thumbnailUrl,
    required this.imageUrl,
    required this.address,
    required this.status,
    required this.comment,
    required this.createdAt,
    required this.location,
    this.isCached = false,
  });

  PosterDetailModel copyWith({
    String? id,
    String? thumbnailUrl,
    String? imageUrl,
    AddressModel? address,
    String? comment,
    PosterStatus? status,
    String? createdAt,
    bool? isCached,
    LatLng? location,
  }) {
    return PosterDetailModel(
      id: id ?? this.id,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isCached: isCached ?? this.isCached,
      location: location ?? this.location,
    );
  }

  factory PosterDetailModel.fromJson(Map<String, dynamic> json) =>
      _$PosterDetailModelFromJson(json.convertLatLongField());

  Map<String, dynamic> toJson() => _$PosterDetailModelToJson(this);
}
