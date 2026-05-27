import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension MembershipsExtension on Profile {
  List<Division> divisions() => memberships?.map((membership) => membership.division).toList() ?? [];

  Division? partyDivision() => divisions().firstWhereOrNull((division) => division.hierarchy == 'GR');

  Division? gjDivision() => divisions().firstWhereOrNull((division) => division.hierarchy == 'GJ');

  Division? kpvDivision() => divisions().firstWhereOrNull((division) => division.hierarchy == 'KPV');

  // TODO #1065: Adjust to OV if teams are available for OVs and user is in an OV
  // ProfilePrivacySettingsOverall minTeamVisibilityOption() => profileVisibilityOptions()[2];
  ProfilePrivacySettingsOverall minTeamVisibilityOption() => ProfilePrivacySettingsOverall.kvWide;

  List<ProfilePrivacySettingsOverall> profileVisibilityOptions() => [
    ProfilePrivacySettingsOverall.private,
    ...(partyDivision()?.level == DivisionLevel.ov ? [ProfilePrivacySettingsOverall.ovWide] : []),
    ProfilePrivacySettingsOverall.kvWide,
    ProfilePrivacySettingsOverall.lvWide,
    ProfilePrivacySettingsOverall.bvWide,
    ProfilePrivacySettingsOverall.public,
  ];
}
