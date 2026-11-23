import 'package:json_annotation/json_annotation.dart';

part 'stand_entry_update_model.g.dart';

@JsonSerializable()
class StandEntryUpdateModel {
  final String entryId;
  final DateTime startAt;
  final DateTime endAt;

  /// Empty for a Termin after today; the API stores an empty count as 0.
  final int? flyerCount;

  StandEntryUpdateModel({required this.entryId, required this.startAt, required this.endAt, this.flyerCount});

  factory StandEntryUpdateModel.fromJson(Map<String, dynamic> json) => _$StandEntryUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$StandEntryUpdateModelToJson(this);
}
