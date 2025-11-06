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

  RouteDetailModel({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    required this.lineString,
    required this.createdAt,
  });

  factory RouteDetailModel.fromJson(Map<String, dynamic> json) => _$RouteDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteDetailModelToJson(this);
}
