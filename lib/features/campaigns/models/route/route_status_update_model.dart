// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/features/campaigns/models/route/route_detail_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_status_update_model.g.dart';

@JsonSerializable()
class RouteStatusUpdateModel {
  final String id;
  final RouteStatus status;
  final RouteDetailModel routeDetail;

  RouteStatusUpdateModel({required this.id, required this.status, required this.routeDetail});

  factory RouteStatusUpdateModel.fromJson(Map<String, dynamic> json) => _$RouteStatusUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteStatusUpdateModelToJson(this);

  RouteStatusUpdateModel copyWith({String? id, RouteStatus? status, RouteDetailModel? routeDetail}) {
    return RouteStatusUpdateModel(
      id: id ?? this.id,
      status: status ?? this.status,
      routeDetail: routeDetail ?? this.routeDetail,
    );
  }
}
