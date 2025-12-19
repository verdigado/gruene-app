import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_divisions_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/campaigns/widgets/search_bar_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class DivisionSearchScreen extends StatefulWidget {
  const DivisionSearchScreen({super.key});

  @override
  State<DivisionSearchScreen> createState() => _DivisionSearchScreenState();
}

class _DivisionSearchScreenState extends State<DivisionSearchScreen> {
  List<Division> _currentSearchResult = [];

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];
    var searchBar = Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SearchBarWidget(
        onExecuteSearch: onSearchDivision,
        onSearchCleared: onSearchCleared,
        hintText: t.campaigns.search.hintTextDivision,
      ),
    );
    widgets.add(searchBar);
    if (_currentSearchResult.isNotEmpty) {
      var listWidgets = _currentSearchResult
          .where((div) => [DivisionLevel.kv].contains(div.level))
          .map((item) => _getSearchResultWidget(item))
          .toList();
      var searchResultList = SingleChildScrollView(child: Column(children: [...listWidgets]));
      widgets.add(searchResultList);
      widgets.add(SizedBox(height: 50));
    }

    return Column(children: widgets);
  }

  Widget _getSearchResultWidget(Division division) {
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
                        child: Text(division.shortDisplayName(), style: theme.textTheme.titleMedium),
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
                        Navigator.pop(context, division);
                      },
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

  void onSearchDivision(String searchText) async {
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    var divisionService = GetIt.I<GrueneApiDivisionsService>();
    var searchResult = await divisionService.searchDivision(searchText);

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
