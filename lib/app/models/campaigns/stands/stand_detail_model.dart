import 'package:gruene_app/app/models/campaigns/posters/poster_create_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_photo_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/utils/extensions.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'stand_detail_model.g.dart';

@JsonSerializable()
class StandDetailModel implements BasicPoi {
  @override
  final String id;
  @override
  final AddressModel address;
  @LatLongConverter()
  final LatLng location;
  final String name;
  final String? description;
  final String? comment;

  /// Sum of the flyer counts of all Termine, calculated by the API. The app never adds them up itself.
  final int flyerCountTotal;

  /// Newest first, as returned by the API. Empty if all Termine were deleted.
  final List<StandEntryModel> entries;

  final List<PosterPhotoModel> photos;
  final String createdAt;
  final bool isCached;

  StandDetailModel({
    required this.id,
    required this.address,
    required this.location,
    required this.name,
    this.description,
    this.comment,
    required this.flyerCountTotal,
    required this.entries,
    required this.photos,
    required this.createdAt,
    this.isCached = false,
  });

  StandDetailModel copyWith({List<StandEntryModel>? entries, bool? isCached}) => StandDetailModel(
    id: id,
    address: address,
    location: location,
    name: name,
    description: description,
    comment: comment,
    flyerCountTotal: flyerCountTotal,
    entries: entries ?? this.entries,
    photos: photos,
    createdAt: createdAt,
    isCached: isCached ?? this.isCached,
  );

  factory StandDetailModel.fromJson(Map<String, dynamic> json) =>
      _$StandDetailModelFromJson(json.convertLatLongField());

  Map<String, dynamic> toJson() => _$StandDetailModelToJson(this);
}
