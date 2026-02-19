import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_model.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class BadgeStatisticsDetail extends StatelessWidget {
  final CampaignStatisticsModel poiStatistics;

  const BadgeStatisticsDetail({required this.poiStatistics, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [Text(t.campaigns.statistic.poi_statistics.my_badges, style: theme.textTheme.titleMedium)],
            ),
          ),
          _getBadgeBox(poiStatistics, context, theme),
        ],
      ),
    );
  }

  Widget _getBadgeBox(CampaignStatisticsModel statistics, BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(bottom: 16, left: 12, right: 12),
      decoration: boxShadowDecoration,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              t.campaigns.statistic.poi_statistics.my_badges_campaign_subtitle,
              style: theme.textTheme.labelSmall,
            ),
          ),
          ..._getBadges(statistics, theme),
        ],
      ),
    );
  }

  List<Widget> _getBadges(CampaignStatisticsModel statistics, ThemeData theme) {
    return [
      _getBadgeRow(t.campaigns.statistic.recorded_doors, statistics.houseStats.own.toInt(), theme),
      _getBadgeRow(t.campaigns.statistic.recorded_posters, statistics.posterStats.own.toInt(), theme),
      _getBadgeRow(t.campaigns.statistic.recorded_flyer, statistics.flyerStats.own.toInt(), theme),
    ];
  }

  Widget _getBadgeRow(String title, int ownCounter, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeColors.textLight)),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark)),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [..._getBadgeIcons(ownCounter, theme)]),
        ],
      ),
    );
  }

  List<Widget> _getBadgeIcons(int value, ThemeData theme) {
    var thresholds = [50, 100, 250, 500];
    var badges = ['bronze', 'silver', 'gold', 'platinum'];
    var widgets = <Widget>[];
    var iconSize = 50.0;
    for (var i = 0; i < thresholds.length; i++) {
      var currentThreshold = thresholds[i];
      if (currentThreshold <= value) {
        widgets.add(
          SizedBox(
            height: iconSize,
            child: Stack(
              children: [
                SvgPicture.asset(
                  'assets/badges/badge_${badges[i]}.svg',
                  fit: BoxFit.fill,
                  height: iconSize,
                  width: iconSize,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      currentThreshold.toString(),
                      style: theme.textTheme.labelMedium!.apply(fontWeightDelta: 3, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          SizedBox(
            height: iconSize,
            child: Stack(
              children: [
                SvgPicture.asset('assets/badges/badge_empty.svg', fit: BoxFit.fill, height: iconSize, width: iconSize),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      currentThreshold.toString(),
                      style: theme.textTheme.labelMedium!.apply(
                        fontWeightDelta: 3,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (currentThreshold != thresholds.last) widgets.add(SizedBox(width: 5));
    }
    return widgets;
  }
}
