import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

DivisionMembership? extractKvMembership(List<DivisionMembership>? memberships) {
  return memberships?.where((membership) => membership.division.level == DivisionLevel.kv).firstOrNull;
}
