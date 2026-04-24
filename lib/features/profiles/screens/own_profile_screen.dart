import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/membership.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/helper/social_media_type_translation.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card_list_item.dart';
import 'package:gruene_app/features/profiles/widgets/profile_header.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class OwnProfileScreen extends StatelessWidget {
  const OwnProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.profiles.profiles),
      body: FutureLoadingScreen(
        load: fetchOwnProfile,
        buildChild: (Profile profile, extra) {
          Iterable<ProfileRole> mandateRoles = profile.roles.where(
            (role) => [ProfileRoleType.mandate, ProfileRoleType.office].contains(role.type),
          );
          Iterable<ProfileRole> sherpaRoles = profile.roles.where((role) => role.type == ProfileRoleType.role);
          Iterable<ProfileTag> skillTags = profile.tags.where((tag) => tag.type == ProfileTagType.skill);
          DivisionMembership? kvMembership = extractKvMembership(profile.memberships);

          return SingleChildScrollView(
            padding: defaultScreenPadding.copyWith(left: 0, right: 0),
            child: Column(
              spacing: 16,
              children: [
                ProfileHeader(profile: profile, onProfileUpdated: extra.update),
                TextListItem(
                  title: t.profiles.myMembershipCard,
                  onPress: () => context.pushNested(Routes.digitalMembershipCard.path),
                ),
                ProfileCard(
                  children: [
                    ProfileCardListItem(title: t.profiles.email, value: profile.email),
                    if (profile.phoneNumbers.isNotEmpty)
                      ProfileCardListItem(title: t.profiles.phoneNumber, value: profile.phoneNumbers.first.number),
                    ProfileCardListItem(title: t.profiles.personalId, value: profile.personalId, copyOnTap: true),
                  ],
                ),
                if (profile.memberships?.isNotEmpty ?? false)
                  ProfileCard(
                    title: t.profiles.memberships,
                    children: profile.memberships!
                        .map(
                          (membership) =>
                              ProfileCardListItem(value: '${membership.division.name1} ${membership.division.name2}'),
                        )
                        .toList(),
                  ),
                if (mandateRoles.isNotEmpty)
                  ProfileCard(
                    title: t.profiles.mandates,
                    children: mandateRoles.map((role) => ProfileCardListItem(value: role.alias)).toList(),
                  ),
                if (sherpaRoles.isNotEmpty)
                  ProfileCard(
                    title: t.profiles.sherpaRole,
                    children: sherpaRoles.map((role) => ProfileCardListItem(value: role.alias)).toList(),
                  ),
                if (skillTags.isNotEmpty)
                  ProfileCard(
                    title: t.profiles.skills,
                    children: skillTags.map((tag) => ProfileCardListItem(value: tag.label)).toList(),
                  ),
                if (kvMembership?.division.urls.isNotEmpty ?? false)
                  ProfileCard(
                    title: t.profiles.myKreisverband,
                    children: kvMembership!.division.urls
                        .map((url) => ProfileCardListItem(value: t.profiles.homepage, url: url))
                        .toList(),
                  ),
                if (profile.socialMedia.isNotEmpty)
                  ProfileCard(
                    title: t.profiles.socialMedia,
                    children: profile.socialMedia
                        .map(
                          (socialMedia) => ProfileCardListItem(
                            value: getSocialMediaTypeTranslation(socialMedia.type),
                            url: socialMedia.url,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
