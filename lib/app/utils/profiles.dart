import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension ProfileExtension on Profile {
  String get fullName => '$firstName $lastName';

  List<Division> get divisions => memberships.map((membership) => membership.division).toList();

  Division? get partyDivision => divisions.firstWhereOrNull((division) => division.hierarchy == 'GR');

  Division? get gjDivision => divisions.firstWhereOrNull((division) => division.hierarchy == 'GJ');

  Division? get kpvDivision => divisions.firstWhereOrNull((division) => division.hierarchy == 'KPV');

  ProfileRole? get partyRole => roles.firstWhereOrNull((role) => role.type == ProfileRoleType.role);

  ProfileRole? get mandate => roles.firstWhereOrNull((role) => role.type == ProfileRoleType.mandate);

  // TODO #1065: Adjust to OV if teams are available for OVs and user is in an OV
  // ProfilePrivacySettingsOverall minTeamVisibilityOption() => profileVisibilityOptions()[2];
  Visibility minTeamVisibilityOption() => Visibility.kvWide;

  List<Visibility> profileVisibilityOptions() => [
    Visibility.private,
    ...(partyDivision?.level == DivisionLevel.ov ? [Visibility.ovWide] : []),
    Visibility.kvWide,
    Visibility.lvWide,
    Visibility.bvWide,
    Visibility.public,
  ];

  UpdateProfile get updateProfile => UpdateProfile(
    email: email,
    phoneNumbers: phoneNumbers
        .map((number) => UpdatePhoneNumber(id: number.id, country: number.country, number: number.number))
        .toList(),
    messengers: messengers
        .map(
          (messenger) => UpdateMessengerEntry(id: messenger.id, externalId: messenger.externalId, type: messenger.type),
        )
        .toList(),
    socialMedia: socialMedia
        .map((socialMedia) => UpdateSocialMediaEntry(id: socialMedia.id, url: socialMedia.url, type: socialMedia.type))
        .toList(),
    tags: tags.map((tag) => tag.externalId!).toList(),
    privacy: privacy,
  );
}

extension PublicProfileExtension on PublicProfile {
  String get fullName => '$firstName $lastName';

  List<Division> get divisions => memberships.map((membership) => membership.division).toList();

  Division? get partyDivision => divisions.firstWhereOrNull((division) => division.hierarchy == 'GR');

  Division? get gjDivision => divisions.firstWhereOrNull((division) => division.hierarchy == 'GJ');

  Division? get kpvDivision => divisions.firstWhereOrNull((division) => division.hierarchy == 'KPV');

  ProfileRole? get partyRole => roles.firstWhereOrNull((role) => role.type == ProfileRoleType.office);

  ProfileRole? get mandate => roles.firstWhereOrNull((role) => role.type == ProfileRoleType.mandate);
}

extension ProfileRoleExtension on ProfileRole {
  // Extract the actual role, e..g `Kreisvorsitzende` from `Kreisvorstand GR - Kreisvorsitzende`
  String get shortName => name.substring(name.indexOf('-') + 2);
}
