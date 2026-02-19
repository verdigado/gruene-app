import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_model.dart';
import 'package:gruene_app/features/campaigns/models/statistics/campaign_statistics_set.dart';
import 'package:gruene_app/features/campaigns/models/team/team_assignment.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';

class PoiStatisticsDetail extends StatefulWidget {
  final CampaignStatisticsModel poiStatistics;
  final TeamMembershipStatistics teamMembershipStatistics;

  const PoiStatisticsDetail({required this.poiStatistics, super.key, required this.teamMembershipStatistics});

  @override
  State<PoiStatisticsDetail> createState() => _PoiStatisticsDetailState();
}

class _PoiStatisticsDetailState extends State<PoiStatisticsDetail> {
  var _selectedStatType = OverallStatTypes.me;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _buildStatScreen(widget.poiStatistics, theme, context);
  }

  Widget _buildStatScreen(CampaignStatisticsModel statistics, ThemeData theme, BuildContext context) {
    var lastUpdateTime = GetIt.I<AppSettings>().campaign.recentPoiStatisticsFetchTimestamp ?? DateTime.now();
    return Container(
      padding: EdgeInsets.all(12),
      color: theme.colorScheme.surfaceDim,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [Text(t.campaigns.statistic.poi_statistics.title, style: theme.textTheme.titleMedium)],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: boxShadowDecoration,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: SegmentedButton<OverallStatTypes>(
                      style: SegmentedButton.styleFrom(
                        selectedForegroundColor: ThemeColors.background,
                        selectedBackgroundColor: ThemeColors.primary,
                        side: BorderSide(color: ThemeColors.textLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        visualDensity: VisualDensity.compact,
                      ),
                      multiSelectionEnabled: false,
                      segments: _getButtonSegments(),
                      selected: {_selectedStatType},
                      showSelectedIcon: false,
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedStatType = newSelection.first;
                        });
                      },
                    ),
                  ),

                  _getCategoryRow(
                    TeamAssignmentType.poster,
                    t.campaigns.statistic.recorded_posters,
                    widget.poiStatistics.posterStats,
                  ),
                  _getCategoryRow(
                    TeamAssignmentType.door,
                    t.campaigns.statistic.recorded_doors,
                    widget.poiStatistics.houseStats,
                  ),
                  _getCategoryRow(
                    TeamAssignmentType.flyer,
                    t.campaigns.statistic.recorded_flyer,
                    widget.poiStatistics.flyerStats,
                  ),
                ],
              ),
            ),
          ),

          Row(
            children: [
              Text(
                '${t.campaigns.statistic.as_at}: ${lastUpdateTime.getAsLocalDateTimeString()} (${t.campaigns.statistic.poi_statistics.update_info})',
                style: theme.textTheme.labelMedium!.apply(color: ThemeColors.textDisabled),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<ButtonSegment<OverallStatTypes>> _getButtonSegments() {
    final theme = Theme.of(context);
    ButtonSegment<OverallStatTypes> getButtonSegment(OverallStatTypes value, String label) => ButtonSegment(
      value: value,
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.apply(
          color: _selectedStatType == value ? ThemeColors.background : ThemeColors.textDark,
        ),
      ),
    );

    var hasSubDivisionData = [
      widget.poiStatistics.posterStats.subDivision,
      widget.poiStatistics.houseStats.subDivision,
      widget.poiStatistics.flyerStats.subDivision,
    ].toList().any((v) => v != null);

    return [
      getButtonSegment(OverallStatTypes.me, t.campaigns.statistic.poi_statistics.me),
      widget.teamMembershipStatistics.teamStatistics.isNotEmpty
          ? getButtonSegment(OverallStatTypes.team, t.campaigns.statistic.poi_statistics.team)
          : null,
      hasSubDivisionData ? getButtonSegment(OverallStatTypes.ov, t.divisions.level.ov.short) : null,
      getButtonSegment(OverallStatTypes.kv, t.divisions.level.kv.short),
      getButtonSegment(OverallStatTypes.lv, t.divisions.level.lv.short),
      getButtonSegment(OverallStatTypes.bv, t.divisions.level.bv.short),
    ].where((segment) => segment != null).map((segment) => segment!).toList();
  }

  Widget _getCategoryRow(TeamAssignmentType category, String title, CampaignStatisticsSet stats) {
    var theme = Theme.of(context);
    var statValue = _getStatValue(stats, () {
      switch (category) {
        case TeamAssignmentType.poster:
          return widget.teamMembershipStatistics.teamStatistics.fold(0, (sum, s) => sum + s.posterCount);
        case TeamAssignmentType.door:
          return widget.teamMembershipStatistics.teamStatistics.fold(
            0,
            (sum, s) => sum + s.closedDoorCount + s.openedDoorCount,
          );
        case TeamAssignmentType.flyer:
          return widget.teamMembershipStatistics.teamStatistics.fold(0, (sum, s) => sum + s.flyerCount);
      }
    });

    return Container(
      padding: EdgeInsetsGeometry.all(4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          Text(
            NumberFormat.decimalPattern(t.$meta.locale.languageCode).format(statValue),
            style: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }

  double _getStatValue(CampaignStatisticsSet stats, double Function() getTeamValue) {
    switch (_selectedStatType) {
      case OverallStatTypes.me:
        return stats.own;
      case OverallStatTypes.team:
        return getTeamValue();
      case OverallStatTypes.ov:
        return stats.subDivision ?? 0;
      case OverallStatTypes.kv:
        return stats.division;
      case OverallStatTypes.lv:
        return stats.state;
      case OverallStatTypes.bv:
        return stats.germany;
    }
  }
}

enum OverallStatTypes { me, team, ov, kv, lv, bv }
