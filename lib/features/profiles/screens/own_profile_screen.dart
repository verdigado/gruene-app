import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
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

class OwnProfileScreen extends StatefulWidget {
  const OwnProfileScreen({super.key});

  @override
  State<OwnProfileScreen> createState() => _OwnProfileScreenState();
}

class _OwnProfileScreenState extends State<OwnProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.profiles.profiles),
      body: FutureLoadingScreen(
        load: fetchOwnProfile,
        buildChild: (Profile data, updateData) {

          Iterable<ProfileRole> mandateRoles =
              data.roles.where((role) => [ProfileRoleType.mandate, ProfileRoleType.office].contains(role.type));
          Iterable<ProfileRole> sherpaRoles = data.roles.where((role) => role.type == ProfileRoleType.role);
          Iterable<ProfileTag> skillTags = data.tags.where((tag) => tag.type == ProfileTagType.skill);
          DivisionMembership? kvMembership = extractKvMembership(data.memberships);

          return ListView(
            children: [
              SizedBox(height: 24),
              ProfileHeader(
                  profile: data,
                  onProfileUpdated: updateData,
              ),
              SizedBox(height: 24),
              TextListItem(
                title: t.profiles.digitalMembershipCard.title,
                onPress: () => context.pushNested(Routes.digitalMembershipCard.path),
              ),
              SizedBox(height: 24),
              ProfileBaseData(profile: data),
              SizedBox(height: 12),
              if (data.memberships?.isNotEmpty ?? false) ...[
                ProfileBox(
                  title: t.profiles.memberships,
                  items: data.memberships!.map(
                    (membership) => ProfileBoxItem(title: '${membership.division.name1} ${membership.division.name2}'),
                  ),
                ),
                SizedBox(height: 12),
              ],
              if (mandateRoles.isNotEmpty) ...[
                ProfileBox(
                  title: t.profiles.mandates,
                  items: mandateRoles.map((role) => ProfileBoxItem(title: role.alias)),
                ),
                SizedBox(height: 12),
              ],
              if (sherpaRoles.isNotEmpty) ...[
                ProfileBox(
                  title: t.profiles.sherpaRole,
                  items: sherpaRoles.map((role) => ProfileBoxItem(title: role.alias)),
                ),
                SizedBox(height: 12),
              ],
              if (skillTags.isNotEmpty) ...[
                ProfileBox(
                  title: t.profiles.skills,
                  items: skillTags.map((tag) => ProfileBoxItem(title: tag.label)),
                ),
                SizedBox(height: 12),
              ],
              if (kvMembership?.division.urls.isNotEmpty ?? false) ...[
                ProfileBox(
                  title: t.profiles.myKreisverband,
                  items: kvMembership!.division.urls
                      .map((url) => ProfileBoxItem(title: t.profiles.homepage, onPress: () => openUrl(url, context))),
                ),
                SizedBox(height: 12),
              ],
              if (data.socialMedia.isNotEmpty) ...[
                ProfileBox(
                  title: t.profiles.socialMedia,
                  items: data.socialMedia.map(
                    (socialMedia) => ProfileBoxItem(
                      title: getSocialMediaTypeTranslation(socialMedia.type),
                      onPress: () => openUrl(socialMedia.url, context),
                    ),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}
