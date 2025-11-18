// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/features/campaigns/models/action_area/action_area_detail_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action_area_update_model.g.dart';

@JsonSerializable()
class ActionAreaUpdateModel {
  final String id;
  final AreaStatus status;
  final ActionAreaDetailModel actionAreaDetail;

  ActionAreaUpdateModel({required this.id, required this.status, required this.actionAreaDetail});

  factory ActionAreaUpdateModel.fromJson(Map<String, dynamic> json) => _$ActionAreaUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActionAreaUpdateModelToJson(this);

  ActionAreaUpdateModel copyWith({String? id, AreaStatus? status, ActionAreaDetailModel? routeDetail}) {
    return ActionAreaUpdateModel(
      id: id ?? this.id,
      status: status ?? this.status,
      actionAreaDetail: routeDetail ?? actionAreaDetail,
    );
  }
}
