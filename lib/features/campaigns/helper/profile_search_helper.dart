import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/screens/teams/profile_search_screen.dart';
import 'package:gruene_app/features/campaigns/widgets/app_route.dart';
import 'package:gruene_app/features/campaigns/widgets/content_page.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileSearchHelper {
  static Future<PublicProfile?>? searchProfile(
    BuildContext context,
    SearchActionState Function(String userId) getActionState,
  ) async {
    var navState = Navigator.of(context, rootNavigator: true);
    var result = (await navState.push(
      AppRoute<PublicProfile?>(
        builder: (context) {
          return ContentPage(
            title: t.campaigns.label,
            contentBackgroundColor: ThemeColors.backgroundSecondary,
            alignment: Alignment.topCenter,
            withScroll: false,
            child: ProfileSearchScreen(getActionText: getActionState),
          );
        },
      ),
    ));
    return result;
  }
}
