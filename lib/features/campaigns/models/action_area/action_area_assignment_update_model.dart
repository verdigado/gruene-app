// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/features/campaigns/models/action_area/action_area_detail_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action_area_assignment_update_model.g.dart';

@JsonSerializable()
class ActionAreaAssignmentUpdateModel {
  final String id;
  final TeamInfo? team;
  final ActionAreaDetailModel actionAreaDetail;

  ActionAreaAssignmentUpdateModel({required this.id, required this.team, required this.actionAreaDetail});

  factory ActionAreaAssignmentUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ActionAreaAssignmentUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActionAreaAssignmentUpdateModelToJson(this);

  ActionAreaAssignmentUpdateModel copyWith({String? id, TeamInfo? team, ActionAreaDetailModel? routeDetail}) {
    return ActionAreaAssignmentUpdateModel(
      id: id ?? this.id,
      team: team ?? this.team,
      actionAreaDetail: routeDetail ?? actionAreaDetail,
    );
  }
}
