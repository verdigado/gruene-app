import 'package:gruene_app/app/models/campaigns/posters/poster_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'stand_create_model.g.dart';

/// A new stand. The API creates a stand only together with its first Termin.
@JsonSerializable()
class StandCreateModel {
  @LatLongConverter()
  final LatLng location;
  final AddressModel address;
  final String name;
  final String? description;
  final String? comment;
  final StandEntryCreateModel firstEntry;

  /// Local files of the photos, uploaded after the stand is created.
  final List<String> imageFileLocations;

  final String campaignId;

  StandCreateModel({
    required this.location,
    required this.address,
    required this.name,
    this.description,
    this.comment,
    required this.firstEntry,
    this.imageFileLocations = const [],
    required this.campaignId,
  });

  factory StandCreateModel.fromJson(Map<String, dynamic> json) => _$StandCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$StandCreateModelToJson(this);
}
