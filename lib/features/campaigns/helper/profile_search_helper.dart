import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/campaigns/helper/paging_helper.dart';
import 'package:gruene_app/features/campaigns/helper/search_action_state.dart';
import 'package:gruene_app/features/campaigns/screens/teams/search_screen.dart';
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
            child: SearchScreen<PublicProfile>(
              searchHintText: t.campaigns.search.hintTextProfile,
              searchDataDelegate: _searchProfile,
              getSearchItemWidget: (item, index, context, closeSearchScreen) =>
                  _getSearchProfileItemWidget(item, index, context, closeSearchScreen, getActionState),
            ),
          );
        },
      ),
    ));
    return result;
  }

  static Future<List<PublicProfile>> _searchProfile(String searchText, int pageKey, int pageSize) async {
    var profileService = GetIt.I<GrueneApiProfileService>();
    return await profileService.searchProfile(
      searchText,
      offset: PagingHelper.getOffsetForPage(pageKey, pageSize),
      limit: pageSize,
    );
  }

  static Widget _getSearchProfileItemWidget(
    PublicProfile item,
    int index,
    BuildContext context,
    void Function(PublicProfile item) closeSearchScreen,
    SearchActionState Function(String userId) getActionText,
  ) {
    var actionState = getActionText(item.userId);
    var theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: boxShadowDecoration,
        padding: EdgeInsets.all(6),
        child: SizedBox(
          height: 112,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(item.fullName(), style: theme.textTheme.titleMedium),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.memberships!.map((m) => m.division.shortDisplayName()).join(', '),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: ThemeColors.background,
                        backgroundColor: ThemeColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          side: BorderSide(color: ThemeColors.primary),
                        ),
                      ),
                      onPressed: !actionState.isEnabled ? null : () => closeSearchScreen(item),

                      child: Text(
                        actionState.actionText,
                        style: theme.textTheme.titleSmall?.apply(color: ThemeColors.background),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
