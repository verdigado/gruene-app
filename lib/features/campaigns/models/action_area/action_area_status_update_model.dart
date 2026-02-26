// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/features/campaigns/models/action_area/action_area_detail_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action_area_status_update_model.g.dart';

@JsonSerializable()
class ActionAreaStatusUpdateModel {
  final String id;
  final AreaStatus status;
  final ActionAreaDetailModel actionAreaDetail;

  ActionAreaStatusUpdateModel({required this.id, required this.status, required this.actionAreaDetail});

  factory ActionAreaStatusUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ActionAreaStatusUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActionAreaStatusUpdateModelToJson(this);

  ActionAreaStatusUpdateModel copyWith({String? id, AreaStatus? status, ActionAreaDetailModel? routeDetail}) {
    return ActionAreaStatusUpdateModel(
      id: id ?? this.id,
      status: status ?? this.status,
      actionAreaDetail: routeDetail ?? actionAreaDetail,
    );
  }
}
