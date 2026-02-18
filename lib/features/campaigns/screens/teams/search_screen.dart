// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/widgets/search_bar_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

typedef SearchDataDelegate<T> = Future<List<T>> Function(String searchText, int pageKey, int pageSize);
typedef GetSearchItemWidgetDelegate<T> =
    Widget Function(T item, int index, BuildContext context, void Function(T item) closeSearchScreen);

class SearchScreen<T> extends StatefulWidget {
  final int pageSize;
  final SearchDataDelegate<T> searchDataDelegate;
  final GetSearchItemWidgetDelegate<T> getSearchItemWidget;

  const SearchScreen({
    super.key,
    required this.searchDataDelegate,
    required this.getSearchItemWidget,
    this.pageSize = 20,
  });

  @override
  State<SearchScreen<T>> createState() => _SearchScreenState();
}

class _SearchScreenState<T> extends State<SearchScreen<T>> {
  PagingState<int, T> _state = PagingState();
  String? _searchText;

  void _fetchNextPage() async {
    if (_state.isLoading) return;

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final newKey = (_state.keys?.last ?? 0) + 1;
      final newItems = await onSearch(newKey);
      final isLastPage = newItems.isEmpty || newItems.length < widget.pageSize;

      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, newItems],
          keys: [...?_state.keys, newKey],
          hasNextPage: !isLastPage,
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _state = _state.copyWith(error: error, isLoading: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var searchBar = Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SearchBarWidget(
        onExecuteSearch: onSearchExecuted,
        onSearchCleared: onSearchCleared,
        hintText: t.campaigns.search.hintTextProfile,
      ),
    );
    var paging = PagedSliverList<int, T>(
      state: _state,
      fetchNextPage: _fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        noItemsFoundIndicatorBuilder: (context) =>
            _searchText == null ? SizedBox.shrink() : Center(child: Text(t.campaigns.search.no_entries_found)),
        itemBuilder: (context, item, index) =>
            widget.getSearchItemWidget(item, index, context, (item) => Navigator.pop(context, item)),
      ),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: searchBar),
        paging,
      ],
    );
  }

  // Widget _getSearchResultWidget(PublicProfile profile) {
  //   var actionState = widget.getActionText(profile.userId);
  //   var theme = Theme.of(context);
  //   return Padding(
  //     padding: EdgeInsets.all(8),
  //     child: Container(
  //       decoration: boxShadowDecoration,
  //       padding: EdgeInsets.all(6),
  //       child: SizedBox(
  //         height: 112,
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.stretch,
  //                 children: [
  //                   Container(
  //                     padding: EdgeInsets.all(6),
  //                     child: Align(
  //                       alignment: Alignment.centerLeft,
  //                       child: Text(profile.fullName(), style: theme.textTheme.titleMedium),
  //                     ),
  //                   ),
  //                   Container(
  //                     padding: EdgeInsets.symmetric(horizontal: 12),
  //                     decoration: BoxDecoration(
  //                       border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
  //                     ),
  //                     child: Align(
  //                       alignment: Alignment.centerLeft,
  //                       child: Text(
  //                         profile.memberships!.map((m) => m.division.shortDisplayName()).join(', '),
  //                         style: theme.textTheme.bodyMedium,
  //                       ),
  //                     ),
  //                   ),
  //                   ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       foregroundColor: ThemeColors.background,
  //                       backgroundColor: ThemeColors.primary,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(24.0),
  //                         side: BorderSide(color: ThemeColors.primary),
  //                       ),
  //                     ),
  //                     onPressed: !actionState.isEnabled
  //                         ? null
  //                         : () {
  //                             Navigator.pop(context, profile);
  //                           },

  //                     child: Text(
  //                       actionState.actionText,
  //                       style: theme.textTheme.titleSmall?.apply(color: ThemeColors.background),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void onSearchCleared() {
    setState(() {
      _searchText = null;
      _state = _state.reset();
    });
  }

  // Future<List<PublicProfile>> onSearchProfileNew(int pageKey) async {
  //   if (_searchText == null) {
  //     return [];
  //   }
  //   var profileService = GetIt.I<GrueneApiProfileService>();
  //   logger.d('Searching for profiles with search text: $_searchText and pageKey: $pageKey');
  //   return await profileService.searchProfile(_searchText!, page: pageKey, pageSize: widget.pageSize);
  // }

  void onSearchExecuted(String searchText) {
    setState(() {
      _searchText = searchText;
      _state = _state.reset();
    });
  }

  Future<List<T>> onSearch(int newKey) async {
    if (_searchText == null) {
      return [];
    }
    return await widget.searchDataDelegate(_searchText!, newKey, widget.pageSize);
  }
}

class SearchActionState {
  final bool isEnabled;
  final String actionText;

  SearchActionState.enabled({required this.actionText}) : isEnabled = true;
  SearchActionState.disabled({required this.actionText}) : isEnabled = false;
}
