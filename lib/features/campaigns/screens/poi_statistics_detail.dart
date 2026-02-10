import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_model.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_set.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:intl/intl.dart';

class PoiStatisticsDetail extends StatelessWidget {
  final CampaignStatisticsModel poiStatistics;

  const PoiStatisticsDetail({required this.poiStatistics, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _buildStatScreen(poiStatistics, theme, context);
  }

  Widget _buildStatScreen(CampaignStatisticsModel statistics, ThemeData theme, BuildContext context) {
    var lastUpdateTime = GetIt.I<AppSettings>().campaign.recentPoiStatisticsFetchTimestamp ?? DateTime.now();
    return Container(
      padding: EdgeInsets.all(16),
      color: theme.colorScheme.surfaceDim,
      child: Column(
        children: [
          _getCategoryBox(stats: statistics.houseStats, theme: theme, title: t.campaigns.statistic.recorded_doors),
          SizedBox(height: 12),
          _getCategoryBox(
            stats: statistics.posterStats,
            theme: theme,
            title: t.campaigns.statistic.recorded_posters,
            subTitle: t.campaigns.statistic.including_damaged_or_taken_down,
          ),
          SizedBox(height: 12),
          _getCategoryBox(stats: statistics.flyerStats, theme: theme, title: t.campaigns.statistic.recorded_flyer),
          Container(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${t.campaigns.statistic.as_at}: ${lastUpdateTime.getAsLocalDateTimeString()} (${t.campaigns.statistic.poi_statistics.update_info})',
                style: theme.textTheme.labelMedium!.apply(color: ThemeColors.textDisabled),
              ),
            ),
          ),
        ],
      ),
    );
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
      boxShadow: [BoxShadow(color: ThemeColors.textDark.withAlpha(10), offset: Offset(2, 4))],
    );
    return Container(
      padding: EdgeInsets.all(16),
      decoration: categoryDecoration,
      child: Column(
        children: [
          Row(children: [Text(title, style: theme.textTheme.titleMedium)]),
          subTitle != null
              ? Row(
                  children: [
                    Text(subTitle, style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.textDisabled)),
                  ],
                )
              : SizedBox(),
          _getDataRow(t.campaigns.statistic.poi_statistics.by_me, stats.own.toInt(), theme),
          _getDataRow(t.campaigns.statistic.poi_statistics.by_my_KV, stats.division.toInt(), theme),
          _getDataRow(t.campaigns.statistic.poi_statistics.by_my_LV, stats.state.toInt(), theme),
          _getDataRow(t.campaigns.statistic.poi_statistics.in_germany, stats.germany.toInt(), theme),
        ],
      ),
    );
  }

  Widget _getDataRow(String key, int value, ThemeData theme) {
    var formatter = NumberFormat.decimalPattern(t.$meta.locale.languageCode);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeColors.textLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark)),
          Text(formatter.format(value), style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.textDark)),
        ],
      ),
    );
  }
}
