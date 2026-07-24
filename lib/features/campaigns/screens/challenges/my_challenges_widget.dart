import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/campaigns/helper/challenge_helper.dart';
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
        onTap: () => ChallengeHelper.openJoinedChallenge(context, challenge),
        child: SizedBox(
          height: 250,
          width: 200,
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
                            top: 40,
                            right: 20,
                            child: Transform.scale(
                              scale: 1.625,
                              child: Opacity(
                                opacity: 0.2,
                                child: ChallengeBadge(
                                  activityType: challenge.activities.firstOrNull?.type ?? ChallengeActivityType.house,
                                  variant: .light,
                                  maxActivityCount: challenge.activities.map((a) => a.count.round()).sum(),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 10,
                            child: ChallengeTimeIndicator(start: challenge.start, end: challenge.end),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 10,
                            child: Text(
                              challengeCampaignName,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: ThemeColors.background),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                            ).withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ThemeColors.background,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                  padding: EdgeInsets.all(10),
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
                            maxLines: 1,
                          ),
                          Text(
                            t.campaigns.challenges.challengeSubTitle(
                              startDate: challenge.start.formattedDate,
                              endDate: challenge.end.formattedDate,
                              participants: challenge.participantCount.round(),
                            ),
                            style: Theme.of(context).textTheme.labelSmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ).withOpacity(0.8),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 180,
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
}
