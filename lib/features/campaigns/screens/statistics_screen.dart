import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_statistics_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: _loadStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return Image.asset(CampaignConstants.dummyImageAssetName);
        }
        return _buildStatScreen(snapshot.data!, theme, context);
      },
    );
  }

  SingleChildScrollView _buildStatScreen(CampaignStatistics statistics, ThemeData theme, BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        color: theme.colorScheme.surfaceDim,
        child: Column(
          children: [
            _getBadgeBox(statistics, context, theme),
            SizedBox(height: 12),
            _getCategoryBox(
              stats: statistics.houseStats,
              theme: theme,
              title: t.campaigns.statistic.recorded_doors,
            ),
            SizedBox(height: 12),
            _getCategoryBox(
              stats: statistics.posterStats,
              theme: theme,
              title: t.campaigns.statistic.recorded_posters,
              subTitle: t.campaigns.statistic.including_damaged_or_taken_down,
            ),
            SizedBox(height: 12),
            _getCategoryBox(
              stats: statistics.flyerStats,
              theme: theme,
              title: t.campaigns.statistic.recorded_flyer,
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Stand: ${DateTime.now().toString()} (${t.campaigns.statistic.update_info})',
                  style: theme.textTheme.labelMedium!.apply(color: ThemeColors.textDisabled),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBadgeBox(CampaignStatistics statistics, BuildContext context, ThemeData theme) {
    var mediaQuery = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      width: mediaQuery.size.width,
      decoration: BoxDecoration(
        color: ThemeColors.background,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(color: ThemeColors.textDark.withAlpha(10), offset: Offset(2, 4)),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              t.campaigns.statistic.my_badges,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              t.campaigns.statistic.my_badges_campaign_subtitle,
              style: theme.textTheme.labelSmall,
            ),
          ),
          ..._getBadges(statistics, theme),
        ],
      ),
    );
  }

  List<Widget> _getBadges(CampaignStatistics statistics, ThemeData theme) {
    return [
      _getBadgeRow(t.campaigns.statistic.recorded_doors, statistics.houseStats.own.toInt(), theme),
      _getBadgeRow(t.campaigns.statistic.recorded_posters, statistics.posterStats.own.toInt(), theme),
      _getBadgeRow(t.campaigns.statistic.recorded_flyer, statistics.flyerStats.own.toInt(), theme),
    ];
  }

  Widget _getBadgeRow(String title, int ownCounter, ThemeData theme) {
    // var rng = Random();
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ThemeColors.textLight),
        ),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ..._getBadgeIcons(ownCounter, theme),
            ],
          ),
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
      if (currentThreshold < value) {
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
                      style: theme.textTheme.labelMedium!.apply(fontWeightDelta: 3),
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
                SvgPicture.asset(
                  'assets/badges/badge_empty.svg',
                  fit: BoxFit.fill,
                  height: iconSize,
                  width: iconSize,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      currentThreshold.toString(),
                      style: theme.textTheme.labelMedium!
                          .apply(fontWeightDelta: 3, color: theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      widgets.add(SizedBox(width: 6));
    }
    return widgets;
  }

  Widget _getCategoryBox({
    required String title,
    String? subTitle,
    required ThemeData theme,
    required CampaignStatisticsSet stats,
  }) {
    var categoryDecoration = BoxDecoration(
      color: ThemeColors.background,
      borderRadius: BorderRadius.circular(19),
      boxShadow: [
        BoxShadow(color: ThemeColors.textDark.withAlpha(10), offset: Offset(2, 4)),
      ],
    );
    return Container(
      padding: EdgeInsets.all(16),
      decoration: categoryDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          subTitle != null
              ? Row(
                  children: [
                    Text(
                      subTitle,
                      style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled),
                    ),
                  ],
                )
              : SizedBox(),
          _getDataRow(t.campaigns.statistic.by_me, stats.own.toInt(), theme),
          _getDataRow(t.campaigns.statistic.by_my_KV, stats.division.toInt(), theme),
          _getDataRow(t.campaigns.statistic.by_my_LV, stats.state.toInt(), theme),
          _getDataRow(t.campaigns.statistic.in_germany, stats.germany.toInt(), theme),
        ],
      ),
    );
  }

  Widget _getDataRow(String key, int value, ThemeData theme) {
    var formatter = NumberFormat('#,##,##0', t.$meta.locale.languageCode);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ThemeColors.textLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark)),
          Text(
            formatter.format(value),
            style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark),
          ),
        ],
      ),
    );
  }

  Future<CampaignStatistics> _loadStatistics() async {
    var statApiService = GetIt.I<GrueneApiCampaignsStatisticsService>();
    return await statApiService.getStatistics();
  }
}
