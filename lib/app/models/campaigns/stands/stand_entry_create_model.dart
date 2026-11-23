import 'package:json_annotation/json_annotation.dart';

part 'stand_entry_create_model.g.dart';

/// A new Termin, either the first one of a new stand or one added to an existing stand.
@JsonSerializable()
class StandEntryCreateModel {
  final DateTime startAt;
  final DateTime endAt;

  /// Empty for a Termin after today; the API stores an empty count as 0.
  final int? flyerCount;

  StandEntryCreateModel({required this.startAt, required this.endAt, this.flyerCount});

  factory StandEntryCreateModel.fromJson(Map<String, dynamic> json) => _$StandEntryCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$StandEntryCreateModelToJson(this);
}
