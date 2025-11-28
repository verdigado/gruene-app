part of '../mixins.dart';

mixin SearchMixin<T extends StatefulWidget> on State<T> {
  var _showSearchBar = false;
  final _campaignSettings = GetIt.I<AppSettings>().campaign;
  List<SearchResultItem>? _searchResult;

  List<Widget> getSearchWidgets(BuildContext context) {
    _searchResult ??= _campaignSettings.searchResult;
    var theme = Theme.of(context);
    var widgets = <Widget>[];

    if (_showSearchBar) {
      widgets.add(
        Positioned.fill(
          child: ModalBarrier(
            dismissible: true,
            color: _searchResult!.isEmpty ? Colors.transparent : ThemeColors.text.withAlpha(150),
            onDismiss: () => setState(() {
              _showSearchBar = false;
            }),
          ),
        ),
      );
    }

    if (!_showSearchBar) {
      var searchButton = Positioned(
        top: 6,
        right: 48,
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: ThemeColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: ThemeColors.textDisabled),
            ),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          ),
          icon: Icon(Icons.search_outlined, color: ThemeColors.textDisabled),
          onPressed: () => setState(() {
            var scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.removeCurrentSnackBar();

            _showSearchBar = true;
          }),
        ),
      );
      widgets.add(searchButton);
    } else {
      var foregroundColor = _campaignSettings.searchString!.isEmpty ? ThemeColors.textDisabled : ThemeColors.secondary;
      var searchBar = Positioned(
        top: 6,
        left: 6,
        right: 52,
        child: SearchBarWidget(
          initialSearchText: _campaignSettings.searchString,
          onExecuteSearch: _searchAddress,
          onSearchFieldChanged: (value) {
            setState(() {
              _campaignSettings.searchString = value;
            });
          },
          onSearchCleared: () {
            setState(() {
              _campaignSettings.searchString = '';
              _searchResult!.clear();
            });
          },
          hintText: t.campaigns.search.hintTextAddress,
        ),
      );
      widgets.add(searchBar);

      var collapseButton = Positioned(
        top: 5,
        right: -6,
        child: ElevatedButton(
          onPressed: _hideSearchBar,
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(side: BorderSide(color: foregroundColor, width: 1)),
            padding: EdgeInsets.all(12),
            backgroundColor: ThemeColors.background,
          ),
          child: Icon(Icons.keyboard_arrow_up, color: foregroundColor),
        ),
      );
      widgets.add(collapseButton);
    }

    if (_showSearchBar && _searchResult!.isNotEmpty) {
      var listWidgets = _searchResult!.map((item) => _getSearchResultWidget(item, theme)).toList();
      for (var i = 0; i < listWidgets.length; i += 2) {
        listWidgets.insert(i, SizedBox(height: 6));
      }

      var searchResultWidget = Positioned(
        top: 66,
        bottom: 6,
        left: 6,
        right: 6,
        child: SingleChildScrollView(child: Column(children: [...listWidgets])),
      );
      widgets.add(searchResultWidget);
    }

    return widgets;
  }

  void _searchAddress(String searchText) async {
    FocusManager.instance.primaryFocus?.unfocus();
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    var nominatimService = GetIt.I<NominatimService>();
    var addressList = await nominatimService.findStreetOrCity(searchText.trim(), CampaignConstants.viewBoxGermany);
    final added = <String>{};

    final distinctAddresses = addressList.where((item) => added.add(item.displayName)).toList();
    var currentMapLocation = _campaignSettings.lastPosition!;
    distinctAddresses.sort((itemA, itemB) {
      // sort list by distance from current map location
      var distanceA = currentMapLocation.getDistance(itemA.location);
      var distanceB = currentMapLocation.getDistance(itemB.location);
      return distanceA.compareTo(distanceB);
    });
    _campaignSettings.searchResult = distinctAddresses;

    if (distinctAddresses.isEmpty && context.mounted) {
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
      _searchResult = distinctAddresses;
    });
  }

  Widget _getSearchResultWidget(SearchResultItem result, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(color: ThemeColors.secondary, borderRadius: BorderRadius.all(Radius.circular(10))),
      padding: EdgeInsets.all(6),
      child: SizedBox(
        height: 91,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () => _moveMapTo(result.location),
                  child: Text(
                    result.displayName,
                    style: theme.textTheme.bodyMedium!.copyWith(color: ThemeColors.background),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _moveMapTo(result.location),
              icon: Icon(Icons.arrow_forward_outlined, color: ThemeColors.background),
            ),
          ],
        ),
      ),
    );
  }

  void navigateMapTo(LatLng location);

  void _moveMapTo(LatLng location) {
    _hideSearchBar();
    navigateMapTo(location);
  }

  void _hideSearchBar() {
    setState(() {
      _showSearchBar = false;
    });
  }
}
