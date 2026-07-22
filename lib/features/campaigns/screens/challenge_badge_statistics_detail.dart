import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/challenge_helper.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_badge.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ChallengeBadgeStatisticsDetail extends StatelessWidget {
  final List<JoinedChallenge> challengeBadges;

  const ChallengeBadgeStatisticsDetail({super.key, required this.challengeBadges});

  @override
  Widget build(BuildContext context) {
    if (challengeBadges.isEmpty) return SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: EdgeInsets.only(bottom: 16, left: 12, right: 12),
        decoration: boxShadowDecoration,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [Text(t.campaigns.statistic.challenge_statistics.title, style: theme.textTheme.titleMedium)],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: .horizontal,
              child: Row(spacing: 8, children: challengeBadges.map((c) => getBadgeIcon(context, c)).toList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBadgeIcon(BuildContext context, JoinedChallenge challenge) {
    return InkWell(
      onTap: () => ChallengeHelper.openChallengeAsJoined(context, challenge),
      child: ChallengeBadge(
        activityType: challenge.activities.firstOrNull?.type ?? ChallengeActivityType.house,
        variant: .dark,
        maxActivityCount: challenge.getProgressInfo().maxActivityCount,
      ),
    );
  }
}
