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

  /// Sum of the flyer counts of all Termine, calculated by the API.
  /// Shown through [displayedFlyerTotal], which covers changes not yet synced.
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

  /// The flyer total to show: [flyerCountTotal] from the API, or, while changes to this stand are still queued,
  /// the provisional total of its Termine with those changes applied (#1266). It equals the API total plus the
  /// queued changes, because the API total is the sum of the Termine it was loaded with.
  int get displayedFlyerTotal => isCached ? entries.fold(0, (sum, entry) => sum + entry.flyerCount) : flyerCountTotal;

  /// The photos, newest first. Photos not uploaded yet have their local file as id, so they are sorted by date.
  List<PosterPhotoModel> get photosNewestFirst => photos.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  StandDetailModel copyWith({List<StandEntryModel>? entries, List<PosterPhotoModel>? photos, bool? isCached}) =>
      StandDetailModel(
        id: id,
        address: address,
        location: location,
        name: name,
        description: description,
        comment: comment,
        flyerCountTotal: flyerCountTotal,
        entries: entries ?? this.entries,
        photos: photos ?? this.photos,
        createdAt: createdAt,
        isCached: isCached ?? this.isCached,
      );

  factory StandDetailModel.fromJson(Map<String, dynamic> json) =>
      _$StandDetailModelFromJson(json.convertLatLongField());

  Map<String, dynamic> toJson() => _$StandDetailModelToJson(this);
}
