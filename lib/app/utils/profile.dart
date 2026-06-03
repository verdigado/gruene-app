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

  UpdateProfile get updateProfile => UpdateProfile(
    email: email,
    phoneNumbers: phoneNumbers
        .map((number) => UpdatePhoneNumber(id: number.id, country: number.country, number: number.number))
        .toList(),
    messengers: messengers
        .map(
          (messenger) => UpdateMessengerEntry(
            id: messenger.id,
            externalId: messenger.externalId,
            type: UpdateMessengerEntryType.values.firstWhere(
              (type) => type.value == messenger.type.value,
              orElse: () => UpdateMessengerEntryType.swaggerGeneratedUnknown,
            ),
          ),
        )
        .toList(),
    socialMedia: socialMedia
        .map(
          (socialMedia) => UpdateSocialMediaEntry(
            id: socialMedia.id,
            url: socialMedia.url,
            type: UpdateSocialMediaEntryType.values.firstWhere(
              (type) => type.value == socialMedia.type.value,
              orElse: () => UpdateSocialMediaEntryType.swaggerGeneratedUnknown,
            ),
          ),
        )
        .toList(),
    tags: tags.map((tag) => tag.externalId!).toList(),
    privacy: privacy,
  );
}
