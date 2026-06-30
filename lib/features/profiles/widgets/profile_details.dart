import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/domain/divisions_api_service.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card_list_item.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileDetails extends StatelessWidget {
  final PublicProfile profile;
  final bool isOwnProfile;

  const ProfileDetails({super.key, required this.profile, this.isOwnProfile = false});

  @override
  Widget build(BuildContext context) {
    final email = profile.email;
    final mandateRoles = profile.displayRoles([ProfileRoleType.mandate]);
    final officeRoles = profile.displayRoles([ProfileRoleType.office]);
    final sherpaRoles = profile.displayRoles([ProfileRoleType.role]);
    final skills = profile.displayTags(ProfileTagType.skill);
    final interests = profile.displayTags(ProfileTagType.interest);
    final divisions = profile.divisions;
    final partyDivision = profile.partyDivision;
    final parentDivisionKeys = [
      partyDivision?.parentDivisionKey(HierarchyLevel.kv),
      partyDivision?.parentDivisionKey(HierarchyLevel.lv),
    ].where((divisionKey) => divisionKey != partyDivision?.divisionKey).nonNulls.toList();
    final theme = Theme.of(context);

    return Column(
      spacing: 16,
      children: [
        if (email != null || profile.phoneNumbers.isNotEmpty || isOwnProfile)
          ProfileCard(
            children: [
              if (email != null)
                ProfileCardListItem(
                  title: t.profiles.email,
                  value: email,
                  onTap: isOwnProfile ? null : () => openMail(email, context),
                ),
              if (profile.phoneNumbers.isNotEmpty)
                ProfileCardListItem(title: t.profiles.phoneNumber, value: profile.phoneNumbers.first.number),
              if (isOwnProfile)
                ProfileCardListItem(title: t.profiles.personalId, value: profile.personalId, copyOnTap: true),
            ],
          ),
        if (divisions.isNotEmpty)
          ProfileCard(
            title: t.profiles.memberships,
            children: [
              FutureLoadingScreen(
                load: parentDivisionKeys.isNotEmpty
                    ? () => loadDivisions(parentDivisionKeys)
                    : () async => <Division>[],
                buildChild: (data, _) => Column(
                  children: [...divisions, ...data].sortByLevel(reverseLevel: true).map((division) {
                    final email = division.emails.firstOrNull?.address;
                    return ProfileCardListItem(
                      value: division.shortDisplayName,
                      url: division.urls.firstOrNull,
                      extraTrailing: email != null
                          ? IconButton(
                              onPressed: () => openMail(email, context),
                              onLongPress: () => Clipboard.setData(ClipboardData(text: email)),
                              icon: Icon(Icons.email_outlined, color: theme.primaryColor),
                            )
                          : null,
                    );
                  }).withDividers(Divider(indent: 16, endIndent: 16)),
                ),
              ),
            ],
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
