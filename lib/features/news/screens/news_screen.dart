import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/main_layout.dart';
import 'package:gruene_app/app/widgets/rounded_icon_button.dart';
import 'package:gruene_app/app/widgets/search_bar.dart';
import 'package:gruene_app/features/news/widgets/news_filter_view.dart';
import 'package:gruene_app/features/news/widgets/news_list.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool showBookmarked = false;
  String query = '';
  List<String> selectedDivisions = [];
  List<String> selectedCategories = [];
  DateTimeRange? dateRange;
  final divisions = ['cat', 'dog', 'mouse'];
  final categories = ['cat', 'dog', 'mouse'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                        // TODO debounce
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
                    onPressed: () => showFullScreenDialog(context, (BuildContext context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return FullScreenDialog(
                            child: NewsFilterView(
                              setDateRange: (DateTimeRange? dateRange) => setState(() {
                                this.dateRange = dateRange;
                              }),
                              dateRange: dateRange,
                              setSelectedDivisions: (List<String> selectedDivisions) {
                                setState(() => this.selectedDivisions = selectedDivisions);
                              },
                              selectedDivisions: selectedDivisions,
                              divisions: divisions,
                              setSelectedCategories: (List<String> selectedCategories) =>
                                  setState(() => this.selectedCategories = selectedCategories),
                              selectedCategories: selectedCategories,
                              categories: categories,
                            ),
                          );
                        },
                      );
                    }),
                    icon: Icons.tune,
                    iconColor: ThemeColors.textDisabled,
                    backgroundColor: theme.colorScheme.surface,
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
