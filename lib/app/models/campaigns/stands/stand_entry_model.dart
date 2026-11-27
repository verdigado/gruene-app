import 'package:json_annotation/json_annotation.dart';

part 'stand_entry_model.g.dart';

/// A Termin of a stand: when it took place and how many flyers were handed out.
@JsonSerializable()
class StandEntryModel {
  final String id;
  final DateTime startAt;
  final DateTime endAt;
  final int flyerCount;

  StandEntryModel({required this.id, required this.startAt, required this.endAt, required this.flyerCount});

  factory StandEntryModel.fromJson(Map<String, dynamic> json) => _$StandEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$StandEntryModelToJson(this);
}
