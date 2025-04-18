import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/news/models/news_model.dart';
import 'package:gruene_app/features/news/utils/utils.dart';
import 'package:gruene_app/features/news/widgets/bookmark_button.dart';

const double imageHeight = 160;

class NewsCard extends StatelessWidget {
  final NewsModel news;

  const NewsCard({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final division = news.division;
    return Container(
      height: 384,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Card(
        color: theme.colorScheme.surface,
        margin: const EdgeInsets.symmetric(vertical: 8),
        // WARNING: The order of stack children is important here!
        // - The decoration container with the linear gradient has to be on top of the image
        // - The InkWell has to be on top of the image and card content
        // - The top bar has to be on top of the InkWell
        child: Stack(
          children: [
            // Teaser image
            Container(
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                image: featuredImage(news),
              ),
            ),
            // Linear gradient on teaser image
            Container(
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    ThemeColors.text.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Card content
            Positioned.fill(
              top: imageHeight,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: theme.textTheme.titleLarge?.apply(fontFamily: 'GrueneType'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        news.summary,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (division != null)
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Chip(
                          label: Text(division.shortDisplayName(), style: theme.textTheme.labelSmall),
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          visualDensity: VisualDensity(vertical: -4),
                          backgroundColor: theme.colorScheme.surface,
                          shape: StadiumBorder(),
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // InkWell/Pressable around the whole card
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.pushNested(news.id),
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            // Top bar with type and bookmark
            Container(
              padding: EdgeInsets.only(left: 16, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    news.type,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.surface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  BookmarkButton(newsId: news.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DecorationImage featuredImage(NewsModel news) {
    final image = news.image;
    return DecorationImage(
      image: image != null
          ? CachedNetworkImageProvider(image.variant('large').url)
          : AssetImage(getPlaceholderImage(news.id)),
      fit: BoxFit.fitWidth,
    );
  }
}
