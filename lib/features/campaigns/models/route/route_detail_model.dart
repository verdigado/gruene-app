// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_detail_model.g.dart';

@JsonSerializable()
class RouteDetailModel {
  final String id;
  final TeamRouteType type;
  final String? name;
  final TeamRouteStatus status;
  final LineString lineString;
  final String createdAt;
  final bool isVirtual;
  final TeamInfo? team;

  const RouteDetailModel({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    required this.lineString,
    required this.createdAt,
    required this.team,
  }) : isVirtual = false;

  RouteDetailModel.virtual({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    required this.lineString,
    required this.createdAt,
    required this.team,
  }) : isVirtual = true;

  factory RouteDetailModel.fromJson(Map<String, dynamic> json) => _$RouteDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteDetailModelToJson(this);

  RouteDetailModel copyWith({
    String? id,
    TeamRouteType? type,
    String? name,
    TeamRouteStatus? status,
    LineString? lineString,
    String? createdAt,
    bool? isVirtual,
    TeamInfo? team,
  }) {
    if (isVirtual ?? this.isVirtual) {
      return RouteDetailModel.virtual(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        status: status ?? this.status,
        lineString: lineString ?? this.lineString,
        createdAt: createdAt ?? this.createdAt,
        team: team ?? this.team,
      );
    } else {
      return RouteDetailModel(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        status: status ?? this.status,
        lineString: lineString ?? this.lineString,
        createdAt: createdAt ?? this.createdAt,
        team: team ?? this.team,
      );
    }
  }
}
