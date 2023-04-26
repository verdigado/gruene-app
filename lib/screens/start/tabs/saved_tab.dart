import 'package:flutter/widgets.dart';
import 'package:gruene_app/net/news/data/news_filters.dart';
import 'package:gruene_app/net/news/repository/news_repositoty.dart';
import 'package:gruene_app/screens/start/tabs/news_card_pagination_list_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SavedTab extends StatefulWidget {
  final repo = NewsRepositoryImpl();
  SavedTab({super.key});

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
  late PagingController<int, News> pagingController;

  @override
  void initState() {
    pagingController = PagingController<int, News>(
        firstPageKey: 0, invisibleItemsThreshold: 5 ~/ 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NewsCardPaginationListView(
      key: GlobalKey(),
      pageSize: 5,
      pagingController: pagingController,
      onBookmarked: (news) {},
      getNews: (pageSize, pagekey) {
        return widget.repo.getNews(pageSize, pagekey, [NewsFilters.saved]);
      },
    );
  }
}
