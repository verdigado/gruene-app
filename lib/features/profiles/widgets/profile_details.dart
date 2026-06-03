import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card_list_item.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileDetails extends StatelessWidget {
  final PublicProfile profile;

  const ProfileDetails({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final email = profile.email;
    final mandateRoles = profile.displayRoles([ProfileRoleType.mandate]);
    final officeRoles = profile.displayRoles([ProfileRoleType.office]);
    final sherpaRoles = profile.displayRoles([ProfileRoleType.role]);
    final skills = profile.displayTags(ProfileTagType.skill);
    final interests = profile.displayTags(ProfileTagType.interest);
    final divisions = profile.divisions;

    return Column(
      spacing: 16,
      children: [
        ProfileCard(
          children: [
            if (email != null) ProfileCardListItem(title: t.profiles.email, value: email),
            if (profile.phoneNumbers.isNotEmpty)
              ProfileCardListItem(title: t.profiles.phoneNumber, value: profile.phoneNumbers.first.number),
            ProfileCardListItem(title: t.profiles.personalId, value: profile.personalId, copyOnTap: true),
          ],
        ),
        if (divisions.isNotEmpty)
          ProfileCard(
            title: t.profiles.memberships,
            children: divisions.map(
              (division) => ProfileCardListItem(value: division.shortDisplayName, url: division.urls.firstOrNull),
            ),
          ),
        if (mandateRoles.isNotEmpty)
          ProfileCard(
            title: t.profiles.mandateRoles,
            children: mandateRoles.map((role) => ProfileCardListItem(value: role)),
          ),
        if (officeRoles.isNotEmpty)
          ProfileCard(
            title: t.profiles.officeRoles,
            children: officeRoles.map((role) => ProfileCardListItem(value: role)),
          ),
        if (sherpaRoles.isNotEmpty)
          ProfileCard(
            title: t.profiles.sherpaRoles,
            children: sherpaRoles.map((role) => ProfileCardListItem(value: role)),
          ),
        if (profile.socialMedia.isNotEmpty)
          ProfileCard(
            title: t.profiles.socialMedia,
            children: profile.socialMedia.map(
              (platform) => ProfileCardListItem(value: platform.label, url: platform.url),
            ),
          ),
        if (skills.isNotEmpty)
          ProfileCard(
            title: t.profiles.skills,
            children: skills.map((tag) => ProfileCardListItem(value: tag)),
          ),
        if (interests.isNotEmpty)
          ProfileCard(
            title: t.profiles.interests,
            children: interests.map((tag) => ProfileCardListItem(value: tag)),
          ),
      ],
    );
  }
}
