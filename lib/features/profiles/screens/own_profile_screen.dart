import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/membership.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/helper/social_media_type_translation.dart';
import 'package:gruene_app/features/profiles/widgets/profile_base_data.dart';
import 'package:gruene_app/features/profiles/widgets/profile_box.dart';
import 'package:gruene_app/features/profiles/widgets/profile_box_item.dart';
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
        buildChild: (Profile data, extra) {
          Iterable<ProfileRole> mandateRoles = data.roles.where(
            (role) => [ProfileRoleType.mandate, ProfileRoleType.office].contains(role.type),
          );
          Iterable<ProfileRole> sherpaRoles = data.roles.where((role) => role.type == ProfileRoleType.role);
          Iterable<ProfileTag> skillTags = data.tags.where((tag) => tag.type == ProfileTagType.skill);
          DivisionMembership? kvMembership = extractKvMembership(data.memberships);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              spacing: 16,
              children: [
                ProfileHeader(profile: data, onProfileUpdated: extra.update),
                TextListItem(
                  title: t.profiles.myMembershipCard,
                  onPress: () => context.pushNested(Routes.digitalMembershipCard.path),
                ),
                ProfileBaseData(profile: data),
                if (data.memberships?.isNotEmpty ?? false)
                  ProfileBox(
                    title: t.profiles.memberships,
                    items: data.memberships!.map(
                      (membership) => ProfileBoxItem(title: '${membership.division.name1} ${membership.division.name2}'),
                    ),
                  ),
                if (mandateRoles.isNotEmpty)
                  ProfileBox(
                    title: t.profiles.mandates,
                    items: mandateRoles.map((role) => ProfileBoxItem(title: role.alias)),
                  ),
                if (sherpaRoles.isNotEmpty)
                  ProfileBox(
                    title: t.profiles.sherpaRole,
                    items: sherpaRoles.map((role) => ProfileBoxItem(title: role.alias)),
                  ),
                if (skillTags.isNotEmpty)
                  ProfileBox(
                    title: t.profiles.skills,
                    items: skillTags.map((tag) => ProfileBoxItem(title: tag.label)),
                  ),
                if (kvMembership?.division.urls.isNotEmpty ?? false)
                  ProfileBox(
                    title: t.profiles.myKreisverband,
                    items: kvMembership!.division.urls.map(
                      (url) => ProfileBoxItem(title: t.profiles.homepage, onPress: () => openUrl(url, context)),
                    ),
                  ),
                if (data.socialMedia.isNotEmpty)
                  ProfileBox(
                    title: t.profiles.socialMedia,
                    items: data.socialMedia.map(
                      (socialMedia) => ProfileBoxItem(
                        title: getSocialMediaTypeTranslation(socialMedia.type),
                        onPress: () => openUrl(socialMedia.url, context),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
