import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/main_layout.dart';
import 'package:gruene_app/app/widgets/rounded_icon_button.dart';
import 'package:gruene_app/app/widgets/search_bar.dart';
import 'package:gruene_app/features/news/widgets/filter_dropdown.dart';
import 'package:gruene_app/features/news/widgets/news_list.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

void _showFullScreenDialog(BuildContext context, WidgetBuilder builder) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.surfaceDim,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surfaceDim,
            leading: IconButton(icon: Icon(Icons.close), onPressed: Navigator.of(context).pop),
          ),
          body: builder(context),
        );
      },
    ),
  );
}

class _NewsScreenState extends State<NewsScreen> {
  bool showFilters = false;
  bool showBookmarked = false;
  String? division;
  String query = '';
  String? category;
  DateTimeRange? dateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ['cat', 'dog', 'mouse'];
    return MainLayout(
      child: Container(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child:
                        CustomSearchBar(setQuery: (String query) => setState(() => this.query = query), query: query),
                  ),
                  // TODO #213: Add bookmarking functionality
                  // SizedBox(width: 8),
                  // RoundedIconButton(
                  //   onPressed: () => setState(() => showBookmarked = !showBookmarked),
                  //   icon: Icons.bookmark_outline,
                  //   iconColor: ThemeColors.textDisabled,
                  //   backgroundColor: theme.colorScheme.surface,
                  //   selected: showBookmarked,
                  //   width: 40,
                  // ),
                  SizedBox(width: 8),
                  RoundedIconButton(
                    onPressed: () => _showFullScreenDialog(context, (BuildContext context) {
                      return FilterDropdown(
                        categories: categories,
                        dateRange: dateRange,
                        setDateRange: (DateTimeRange? dateRange) => setState(() => this.dateRange = dateRange),
                      );
                    }),
                    icon: Icons.tune,
                    iconColor: ThemeColors.textDisabled,
                    backgroundColor: theme.colorScheme.surface,
                    selected: showFilters,
                    width: 40,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Expanded(child: NewsList()),
          ],
        ),
      ),
    );
  }
}
