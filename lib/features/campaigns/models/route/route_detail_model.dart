// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_detail_model.g.dart';

@JsonSerializable()
class RouteDetailModel {
  final String id;
  final RouteType type;
  final String? name;
  final RouteStatus status;
  final LineString lineString;
  final String createdAt;
  final bool isVirtual;

  const RouteDetailModel({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    required this.lineString,
    required this.createdAt,
  }) : isVirtual = false;

  RouteDetailModel.virtual({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    required this.lineString,
    required this.createdAt,
  }) : isVirtual = true;

  factory RouteDetailModel.fromJson(Map<String, dynamic> json) => _$RouteDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteDetailModelToJson(this);

  RouteDetailModel copyWith({
    String? id,
    RouteType? type,
    String? name,
    RouteStatus? status,
    LineString? lineString,
    String? createdAt,
    bool? isVirtual,
  }) {
    if (isVirtual ?? this.isVirtual) {
      return RouteDetailModel.virtual(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        status: status ?? this.status,
        lineString: lineString ?? this.lineString,
        createdAt: createdAt ?? this.createdAt,
      );
    } else {
      return RouteDetailModel(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        status: status ?? this.status,
        lineString: lineString ?? this.lineString,
        createdAt: createdAt ?? this.createdAt,
      );
    }
  }
}
