import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/models/team/team_assignment.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';

class TeamStatisticsCategoryDetail extends StatefulWidget {
  final TeamAssignmentType category;
  final TeamStatisticsCategory statisticData;

  const TeamStatisticsCategoryDetail({super.key, required this.category, required this.statisticData});

  @override
  State<TeamStatisticsCategoryDetail> createState() => _TeamStatisticsCategoryDetailState();
}

class _TeamStatisticsCategoryDetailState extends State<TeamStatisticsCategoryDetail> {
  DivisionLevel _selectedDivisionType = DivisionLevel.kv;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: boxShadowDecoration,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: SvgPicture.asset(widget.category.getAssetLocationByAssignmentType()),
                    ),
                    SizedBox(width: 4),
                    Text(_getTitle(), style: theme.textTheme.titleSmall),
                  ],
                ),
                SegmentedButton<DivisionLevel>(
                  style: SegmentedButton.styleFrom(
                    selectedForegroundColor: ThemeColors.background,
                    selectedBackgroundColor: ThemeColors.primary,
                    side: BorderSide(color: ThemeColors.textLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    visualDensity: VisualDensity.compact,
                  ),
                  multiSelectionEnabled: false,
                  segments: _getButtonSegments(),
                  selected: {_selectedDivisionType},
                  showSelectedIcon: false,
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedDivisionType = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            Column(children: _getTeamStats()),
          ],
        ),
      ),
    );
  }

  List<ButtonSegment<DivisionLevel>> _getButtonSegments() {
    var theme = Theme.of(context);
    ButtonSegment<DivisionLevel> getButtonSegment(DivisionLevel value, String label) => ButtonSegment(
      value: value,
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.apply(
          color: _selectedDivisionType == value ? ThemeColors.background : ThemeColors.textDark,
        ),
      ),
    );

    return [
      getButtonSegment(DivisionLevel.kv, t.divisions.level.kv.short),
      getButtonSegment(DivisionLevel.lv, t.divisions.level.lv.short),
      getButtonSegment(DivisionLevel.bv, t.divisions.level.bv.short),
    ];
  }

  List<Widget> _getTeamStats() {
    var categoryStats = widget.statisticData;
    var stats = _getStatResults(categoryStats);

    stats.sort((a, b) => b.count.compareTo(a.count));

    return stats.indexed.map(_getStatRow).toList();
  }

  List<TeamStatisticsCategoryItem> _getStatResults(TeamStatisticsCategory categoryStats) {
    switch (_selectedDivisionType) {
      case DivisionLevel.kv:
        return categoryStats.division;
      case DivisionLevel.lv:
        return categoryStats.state;
      case DivisionLevel.bv:
        return categoryStats.germany;
      case DivisionLevel.ov:
      case DivisionLevel.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }

  Widget _getStatRow((int, TeamStatisticsCategoryItem) e) {
    var theme = Theme.of(context);
    var index = e.$1 + 1;
    var item = e.$2;
    Widget memberItemWidget = Container(
      padding: EdgeInsetsGeometry.all(4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(color: ThemeColors.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: theme.textTheme.displayMedium?.apply(color: ThemeColors.background),
                  ),
                ),
              ),
              SizedBox(width: 16),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 165),
                      child: Text(
                        item.teamName,
                        style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.end,
                      NumberFormat.decimalPattern(t.$meta.locale.languageCode).format(item.count),
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 235),
                      child: Text(item.division, style: theme.textTheme.labelMedium, overflow: TextOverflow.ellipsis),
                    ),
                    Row(
                      children: [
                        Icon(Icons.group_outlined, size: 16),
                        SizedBox(width: 2),
                        Text(
                          NumberFormat.decimalPattern(t.$meta.locale.languageCode).format(item.teamMemberCount),
                          style: theme.textTheme.labelMedium,
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.event_outlined, size: 16),
                        SizedBox(width: 2),
                        Text(item.teamCreatedAt.getAsLocalDateString(), style: theme.textTheme.labelMedium),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (item.teamMemberCount > 0) {
      memberItemWidget.disable();
    }
    return memberItemWidget;
  }

  String _getTitle() {
    switch (widget.category) {
      case TeamAssignmentType.poster:
        return t.campaigns.statistic.recorded_posters;
      case TeamAssignmentType.door:
        return t.campaigns.statistic.recorded_doors;
      case TeamAssignmentType.flyer:
        return t.campaigns.statistic.recorded_flyer;
    }
  }
}
