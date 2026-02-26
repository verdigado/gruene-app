import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_divisions_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/paging_helper.dart';
import 'package:gruene_app/features/campaigns/screens/teams/search_screen.dart';
import 'package:gruene_app/features/campaigns/widgets/app_route.dart';
import 'package:gruene_app/features/campaigns/widgets/content_page.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class DivisionSearchHelper {
  static Future<Division?>? searchDivision(
    BuildContext context, {
    DivisionLevel? level,
    List<String>? divisionKeysFilter,
  }) async {
    var navState = Navigator.of(context, rootNavigator: true);
    final result = await navState.push(
      AppRoute<Division?>(
        builder: (context) {
          return ContentPage(
            title: t.campaigns.label,
            showBackButton: true,
            contentBackgroundColor: ThemeColors.backgroundSecondary,
            alignment: Alignment.topCenter,
            withScroll: false,
            child: SearchScreen<Division>(
              searchHintText: t.campaigns.search.hintTextDivision,
              getSearchItemWidget: _getSearchItemWidget,
              searchDataDelegate: (String searchText, int pageKey, int pageSize) => _getSearchDivisonDelegate(
                searchText,
                pageKey,
                pageSize,
                level: level,
                divisionKeysFilter: divisionKeysFilter,
              ),
            ),
          );
        },
      ),
    );
    return result;
  }

  static Widget _getSearchItemWidget(
    Division item,
    int index,
    BuildContext context,
    void Function(Division item) closeSearchScreen,
  ) {
    var theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: boxShadowDecoration,
        padding: EdgeInsets.all(6),
        child: SizedBox(
          height: 86,
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
                        child: Text(item.shortName, style: theme.textTheme.titleMedium),
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
                      onPressed: () => closeSearchScreen(item),
                      child: Text(
                        t.campaigns.team.select_as_division,
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

  static Future<List<Division>> _getSearchDivisonDelegate(
    String searchText,
    int pageKey,
    int pageSize, {
    DivisionLevel? level,
    List<String>? divisionKeysFilter,
  }) async {
    var divisionService = GetIt.I<GrueneApiDivisionsService>();
    var searchResult = await divisionService.searchDivision(
      searchTerm: searchText,
      offset: PagingHelper.getOffsetForPage(pageKey, pageSize),
      limit: pageSize,
      level: level,
      divisionKeys: divisionKeysFilter,
    );
    return searchResult;
  }
}
