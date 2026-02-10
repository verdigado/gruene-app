import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/models/team/team_assignment.dart';
import 'package:gruene_app/features/campaigns/screens/team_statistics_category_detail.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class TeamStatisticsDetail extends StatefulWidget {
  final TeamStatistics teamStatistics;

  const TeamStatisticsDetail({required this.teamStatistics, super.key});

  @override
  State<TeamStatisticsDetail> createState() => _TeamStatisticsDetailState();
}

class _TeamStatisticsDetailState extends State<TeamStatisticsDetail> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [Text(t.campaigns.statistic.team_statistics.title, style: theme.textTheme.titleMedium)],
            ),
          ),
          TeamStatisticsCategoryDetail(
            category: TeamAssignmentType.poster,
            statisticData: widget.teamStatistics.poster,
          ),
          TeamStatisticsCategoryDetail(category: TeamAssignmentType.door, statisticData: widget.teamStatistics.house),
          TeamStatisticsCategoryDetail(category: TeamAssignmentType.flyer, statisticData: widget.teamStatistics.flyer),
        ],
      ),
    );
  }
}
