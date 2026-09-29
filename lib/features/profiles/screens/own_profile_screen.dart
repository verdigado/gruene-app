import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/widgets/profile_details.dart';
import 'package:gruene_app/features/profiles/widgets/profile_header.dart';
import 'package:gruene_app/features/profiles/widgets/profile_visibility_setting.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/prototype/flows/guest/guest_flow.dart';
import 'package:gruene_app/prototype/flows/guest/guest_screens.dart';
import 'package:gruene_app/prototype/flows/guest/guest_terms.dart';
import 'package:gruene_app/prototype/prototype.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class OwnProfileScreen extends StatelessWidget {
  const OwnProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.profiles.profiles),
      body: FutureLoadingScreen(
        load: fetchOwnProfile,
        buildChild: (Profile profile, extra) => SingleChildScrollView(
          padding: verticalScreenPadding,
          child: Column(
            spacing: 16,
            children: [
              OwnProfileHeader(profile: profile, update: extra.update),
              Column(
                children: [
                  TextListItem(title: t.profiles.search, onPress: () => context.pushNested(Routes.profileSearch.path)),
                  // PROTOTYPE: guest administration lives with people, not with
                  // the campaign — it outlives the Wahlkampf-only scope.
                  if (guestAdministration.isOn && prototypePersona.value.canInviteGuests)
                    TextListItem(
                      title: terms.accesses,
                      onPress: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute<void>(builder: (_) => const GuestAdministrationScreen())),
                    ),
                  TextListItem(
                    title: t.profiles.myMembershipCard,
                    onPress: () => context.pushNested(Routes.membershipCard.path),
                  ),
                  TextListItem(
                    title: t.profiles.visibility.visibility,
                    onPress: () async {
                      final newProfile = await showProfileVisibilitySetting(context, profile);
                      if (newProfile != null) {
                        extra.update(newProfile);
                      }
                    },
                  ),
                ],
              ),
              ProfileDetails(profile: profile.publicProfile, isOwnProfile: true),
            ],
          ),
        ),
      ),
    );
  }
}
