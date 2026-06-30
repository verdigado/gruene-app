import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/domain/divisions_api_service.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/section_card.dart';
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
          SectionCard(
            children: [
              if (email != null)
                SectionCardListItem(
                  title: t.profiles.email,
                  value: email,
                  onTap: isOwnProfile ? null : () => openMail(email, context),
                ),
              if (profile.phoneNumbers.isNotEmpty)
                SectionCardListItem(title: t.profiles.phoneNumber, value: profile.phoneNumbers.first.number),
              if (isOwnProfile)
                SectionCardListItem(title: t.profiles.personalId, value: profile.personalId, copyOnTap: true),
            ],
          ),
        if (divisions.isNotEmpty)
          SectionCard(
            title: t.profiles.memberships,
            children: [
              FutureLoadingScreen(
                load: parentDivisionKeys.isNotEmpty
                    ? () => loadDivisions(parentDivisionKeys)
                    : () async => <Division>[],
                buildChild: (data, _) => Column(
                  children: [...divisions, ...data]
                      .sortByLevel(reverseLevel: true)
                      .map((division) {
                        final email = division.emails.firstOrNull?.address;
                        return SectionCardListItem(
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
                      })
                      .withDividers(Divider(indent: 16, endIndent: 16)),
                ),
              ),
            ],
          ),
        if (mandateRoles.isNotEmpty)
          SectionCard(
            title: t.profiles.mandateRoles,
            children: mandateRoles.map((role) => SectionCardListItem(value: role)),
          ),
        if (officeRoles.isNotEmpty)
          SectionCard(
            title: t.profiles.officeRoles,
            children: officeRoles.map((role) => SectionCardListItem(value: role)),
          ),
        if (sherpaRoles.isNotEmpty)
          SectionCard(
            title: t.profiles.sherpaRoles,
            children: sherpaRoles.map((role) => SectionCardListItem(value: role)),
          ),
        if (profile.socialMedia.isNotEmpty)
          SectionCard(
            title: t.profiles.socialMedia,
            children: profile.socialMedia.map(
              (platform) => SectionCardListItem(value: platform.label, url: platform.url),
            ),
          ),
        if (skills.isNotEmpty)
          SectionCard(
            title: t.profiles.skills,
            children: skills.map((tag) => SectionCardListItem(value: tag)),
          ),
        if (interests.isNotEmpty)
          SectionCard(
            title: t.profiles.interests,
            children: interests.map((tag) => SectionCardListItem(value: tag)),
          ),
      ],
    );
  }
}
