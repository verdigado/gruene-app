import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension ProfileExtension on Profile {
  String get fullName => '$firstName $lastName';

  List<Division> get divisions => publicProfile.divisions;

  Division? get partyDivision => publicProfile.partyDivision;

  // TODO #1065: Adjust to OV if teams are available for OVs and user is in an OV
  // ProfilePrivacySettingsOverall minTeamVisibilityOption() => profileVisibilityOptions()[2];
  Visibility minTeamVisibilityOption() => Visibility.kvWide;

  List<Visibility> profileVisibilityOptions() => [
    Visibility.private,
    ...(partyDivision?.level == HierarchyLevel.ov ? [Visibility.ovWide] : []),
    Visibility.kvWide,
    Visibility.lvWide,
    Visibility.bvWide,
    Visibility.public,
  ];

  PublicProfile get publicProfile => PublicProfile(
    id: id,
    userId: userId,
    personalId: personalId,
    username: username,
    firstName: firstName,
    lastName: lastName,
    image: image,
    phoneNumbers: phoneNumbers,
    messengers: messengers,
    socialMedia: socialMedia,
    tags: tags,
    joinedAt: joinedAt,
    memberships: memberships,
    roles: roles,
    achievements: achievements,
    email: email,
  );

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

  Division? get partyDivision => divisions.firstWhereOrNull((division) => division.hierarchy == HierarchyType.gr);

  List<String> displayRoles({List<ProfileRoleType>? types}) =>
      roles.where((role) => types == null || types.contains(role.type)).map((role) => role.shortName).toSet().toList();

  List<String> displayTags(ProfileTagType? type) =>
      tags.where((tag) => type == null || tag.type == type).map((tag) => tag.label).toSet().toList();
}

extension ProfileRoleExtension on ProfileRole {
  // Extract the actual role, e..g `Kreisvorsitzende` from `Kreisvorstand GR - Kreisvorsitzende`
  String get shortName => name.contains('-') ? name.substring(name.indexOf('-') + 2) : name;
}

extension SocialMediaEntryExtension on SocialMediaEntry {
  String get label => switch (type) {
    SocialMediaType.facebook => t.profiles.socialMediaType.facebook,
    SocialMediaType.instagram => t.profiles.socialMediaType.instagram,
    SocialMediaType.mastodon => t.profiles.socialMediaType.mastodon,
    SocialMediaType.twitter => t.profiles.socialMediaType.twitter,
    SocialMediaType.chatbegruenung => t.profiles.socialMediaType.chatbegruenung,
    SocialMediaType.swaggerGeneratedUnknown => '',
  };
}
