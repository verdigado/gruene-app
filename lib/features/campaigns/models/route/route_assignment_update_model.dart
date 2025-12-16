// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/features/campaigns/models/route/route_detail_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_assignment_update_model.g.dart';

@JsonSerializable()
class RouteAssignmentUpdateModel {
  final String id;
  final TeamRoute team;
  final RouteDetailModel routeDetail;

  RouteAssignmentUpdateModel({required this.id, required this.team, required this.routeDetail});

  factory RouteAssignmentUpdateModel.fromJson(Map<String, dynamic> json) => _$RouteAssignmentUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteAssignmentUpdateModelToJson(this);

  RouteAssignmentUpdateModel copyWith({String? id, TeamRoute? team, RouteDetailModel? routeDetail}) {
    return RouteAssignmentUpdateModel(
      id: id ?? this.id,
      team: team ?? this.team,
      routeDetail: routeDetail ?? this.routeDetail,
    );
  }
}
