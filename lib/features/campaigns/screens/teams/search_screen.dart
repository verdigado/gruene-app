// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/helper/new_page_error_indicator.dart';
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
  final String searchHintText;

  const SearchScreen({
    super.key,
    required this.searchDataDelegate,
    required this.getSearchItemWidget,
    required this.searchHintText,
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
        hintText: widget.searchHintText,
      ),
    );
    var paging = PagedSliverList<int, T>(
      state: _state,
      fetchNextPage: _fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        noItemsFoundIndicatorBuilder: (context) =>
            _searchText == null ? SizedBox.shrink() : Center(child: Text(t.campaigns.search.no_entries_found)),
        newPageErrorIndicatorBuilder: (context) => NewPageErrorIndicator(onTap: _fetchNextPage),
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

  void onSearchCleared() {
    setState(() {
      _searchText = null;
      _state = _state.reset();
    });
  }

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
