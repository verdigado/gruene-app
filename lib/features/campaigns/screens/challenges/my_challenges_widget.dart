import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_badge.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_time_indicator.dart';
import 'package:gruene_app/features/campaigns/screens/progress_with_label.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class MyChallengesWidget extends StatelessWidget {
  final List<JoinedChallenge> joinedChallenges;
  final List<Campaign> knownCampaigns;

  const MyChallengesWidget({super.key, required this.joinedChallenges, required this.knownCampaigns});

  @override
  Widget build(BuildContext context) {
    if (joinedChallenges.isEmpty) return SizedBox.shrink();
    joinedChallenges.sort((a, b) => a.end.compareTo(b.end));

    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.only(top: 20, left: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [Text(t.campaigns.challenges.myChallengeLabel, style: Theme.of(context).textTheme.labelMedium)],
          ),
          SizedBox(
            width: mediaQuery.size.width - 16,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [...joinedChallenges.map((challenge) => getActiveChallengeCard(challenge, context))],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getActiveChallengeCard(JoinedChallenge challenge, BuildContext context) {
    String challengeCampaignName = challenge.campaignId == null
        ? ' '
        : knownCampaigns.firstWhereOrNull((c) => c.id == challenge.campaignId)?.name ?? t.common.unknown;
    var progressInfo = challenge.getProgressInfo();
    return Card(
      child: InkWell(
        onTap: () => openChallenge(context, challenge),
        child: SizedBox(
          height: 300,
          width: 250,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [ThemeColors.primary, ThemeColors.secondary],
                        ),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            right: -10,
                            child: SizedBox(
                              height: 210,
                              child: ChallengeBadge(
                                activityType: challenge.activities.firstOrNull?.type ?? ChallengeActivityType.house,
                                variant: .dark,
                                maxActivityCount: challenge.activities.map((a) => a.count.round()).sum(),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: ChallengeTimeIndicator(start: challenge.start, end: challenge.end),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 16,
                            child: Text(
                              challengeCampaignName,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: ThemeColors.background),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            challenge.title,
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Text(
                            t.campaigns.challenges.challengeSubTitle(
                              startDate: challenge.start.formattedDateTime,
                              endDate: challenge.end.formattedDateTime,
                              participants: challenge.activities.length,
                            ),
                            style: Theme.of(context).textTheme.labelMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 234,
                            child: ProgressWithLabel(value: progressInfo.progressValue, label: progressInfo.label),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openChallenge(BuildContext context, JoinedChallenge challenge) {
    context.push(RouteLocations.getRoute([RouteLocations.campaignChallengesDetail, challenge.id]), extra: challenge);
  }
}
