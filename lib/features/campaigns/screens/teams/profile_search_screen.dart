// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/features/campaigns/widgets/search_bar_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ProfileSearchScreen extends StatefulWidget {
  final SearchActionState Function(String userId) getActionText;

  const ProfileSearchScreen({super.key, required this.getActionText});

  @override
  State<ProfileSearchScreen> createState() => _ProfileSearchScreenState();
}

class SearchActionState {
  final bool isEnabled;
  final String actionText;

  SearchActionState.enabled({required this.actionText}) : isEnabled = true;
  SearchActionState.disabled({required this.actionText}) : isEnabled = false;
}

class _ProfileSearchScreenState extends State<ProfileSearchScreen> {
  PagingState<int, PublicProfile> _state = PagingState();
  String? _searchText;
  static const _pageSize = 20;

  void _fetchNextPage() async {
    if (_state.isLoading) return;

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final newKey = (_state.keys?.last ?? 0) + 1;
      final newItems = await onSearchProfileNew(newKey);
      final isLastPage = newItems.isEmpty || newItems.length < _pageSize;

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
        onExecuteSearch: onSearchProfileExecuted,
        onSearchCleared: onSearchCleared,
        hintText: t.campaigns.search.hintTextProfile,
      ),
    );
    var paging = PagedSliverList<int, PublicProfile>(
      state: _state,
      fetchNextPage: _fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        noItemsFoundIndicatorBuilder: (context) =>
            _searchText == null ? SizedBox.shrink() : Center(child: Text(t.campaigns.search.no_entries_found)),
        itemBuilder: (context, item, index) => _getSearchResultWidget(item),
      ),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: searchBar),
        paging,
      ],
    );
  }

  Widget _getSearchResultWidget(PublicProfile profile) {
    var actionState = widget.getActionText(profile.userId);
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
                      onPressed: !actionState.isEnabled
                          ? null
                          : () {
                              Navigator.pop(context, profile);
                            },

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

  void onSearchCleared() {
    setState(() {
      _searchText = null;
      _state = _state.reset();
    });
  }

  Future<List<PublicProfile>> onSearchProfileNew(int pageKey) async {
    if (_searchText == null) {
      return [];
    }
    var profileService = GetIt.I<GrueneApiProfileService>();
    logger.d('Searching for profiles with search text: $_searchText and pageKey: $pageKey');
    return await profileService.searchProfile(_searchText!, page: pageKey, pageSize: _pageSize);
  }

  void onSearchProfileExecuted(String searchText) {
    setState(() {
      _searchText = searchText;
      _state = _state.reset();
    });
  }
}
