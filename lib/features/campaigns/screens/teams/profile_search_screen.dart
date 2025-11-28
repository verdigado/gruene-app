// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/campaigns/widgets/search_bar_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileSearchScreen extends StatefulWidget {
  final String actionText;

  const ProfileSearchScreen({super.key, required this.actionText});

  @override
  State<ProfileSearchScreen> createState() => _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends State<ProfileSearchScreen> {
  List<PublicProfile> _currentSearchResult = [];

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];
    var searchBar = Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SearchBarWidget(
        onExecuteSearch: onSearchProfile,
        onSearchCleared: onSearchCleared,
        hintText: t.campaigns.search.hintTextProfile,
      ),
    );
    widgets.add(searchBar);
    if (_currentSearchResult.isNotEmpty) {
      var listWidgets = _currentSearchResult.map((item) => _getSearchResultWidget(item)).toList();
      var searchResultList = SingleChildScrollView(child: Column(children: [...listWidgets]));
      widgets.add(searchResultList);
      widgets.add(SizedBox(height: 50));
    }

    return Column(children: widgets);
  }

  Widget _getSearchResultWidget(PublicProfile profile) {
    var theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.background,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
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
                        child: Text(profile.fullName(), style: theme.textTheme.titleMedium),
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
                          profile.memberships!.map((m) => m.division.shortDisplayName()).join(', '),
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
                      onPressed: () {
                        Navigator.pop(context, profile);
                      },
                      child: Text(
                        widget.actionText,
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

  void onSearchProfile(String searchText) async {
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    var divisionService = GetIt.I<GrueneApiProfileService>();
    var searchResult = await divisionService.searchProfile(searchText);

    if (searchResult.isEmpty) {
      scaffoldMessenger.removeCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(t.campaigns.search.no_entries_found),
          duration: Duration(seconds: 2),
          showCloseIcon: true,
        ),
      );
    }

    setState(() {
      _currentSearchResult = searchResult;
    });
  }

  void onSearchCleared() {}
}
