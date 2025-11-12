// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action_area_detail_model.g.dart';

@JsonSerializable()
class ActionAreaDetailModel {
  final String id;
  final AreaType type;
  final String? name;
  final String? comment;
  final AreaStatus status;
  final Polygon polygon;
  final String createdAt;
  final bool isVirtual;

  const ActionAreaDetailModel({
    required this.id,
    required this.type,
    required this.name,
    required this.comment,
    required this.status,
    required this.polygon,
    required this.createdAt,
  }) : isVirtual = false;

  ActionAreaDetailModel.virtual({
    required this.id,
    required this.type,
    required this.name,
    required this.comment,
    required this.status,
    required this.polygon,
    required this.createdAt,
  }) : isVirtual = true;

  factory ActionAreaDetailModel.fromJson(Map<String, dynamic> json) => _$ActionAreaDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActionAreaDetailModelToJson(this);

  ActionAreaDetailModel copyWith({
    String? id,
    AreaType? type,
    String? name,
    String? comment,
    AreaStatus? status,
    Polygon? polygon,
    String? createdAt,
    bool? isVirtual,
  }) {
    if (isVirtual ?? this.isVirtual) {
      return ActionAreaDetailModel.virtual(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        comment: comment ?? this.comment,
        status: status ?? this.status,
        polygon: polygon ?? this.polygon,
        createdAt: createdAt ?? this.createdAt,
      );
    } else {
      return ActionAreaDetailModel.virtual(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        comment: comment ?? this.comment,
        status: status ?? this.status,
        polygon: polygon ?? this.polygon,
        createdAt: createdAt ?? this.createdAt,
      );
    }
  }
}
