// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gruene_app/features/campaigns/models/route/route_detail_model.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_update_model.g.dart';

@JsonSerializable()
class RouteUpdateModel {
  final String id;
  final RouteStatus status;
  final RouteDetailModel routeDetail;

  RouteUpdateModel({required this.id, required this.status, required this.routeDetail});

  factory RouteUpdateModel.fromJson(Map<String, dynamic> json) => _$RouteUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteUpdateModelToJson(this);

  RouteUpdateModel copyWith({String? id, RouteStatus? status, RouteDetailModel? routeDetail}) {
    return RouteUpdateModel(
      id: id ?? this.id,
      status: status ?? this.status,
      routeDetail: routeDetail ?? this.routeDetail,
    );
  }
}
