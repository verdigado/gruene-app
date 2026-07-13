import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_time_indicator.dart';
import 'package:gruene_app/features/campaigns/screens/progress_with_label.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class MyChallengesWidget extends StatelessWidget {
  final List<Challenge> joinedChallenges;

  const MyChallengesWidget({super.key, required this.joinedChallenges});

  @override
  Widget build(BuildContext context) {
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

  Widget getActiveChallengeCard(Challenge challenge, BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => openChallenge(context, challenge),
        child: SizedBox(
          height: 300,
          width: 250,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [ThemeColors.primary, ThemeColors.secondary],
                    ),
                    // color: ThemeColors.primary,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 16,
                        left: 16,
                        child: ChallengeTimeIndicator(start: challenge.start, end: challenge.end),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 16,
                        child: Text(
                          'Abgeordnetenhauswahl Berlin 2026',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: ThemeColors.background),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                        children: [SizedBox(width: 234, child: ProgressWithLabel(value: 0.37, label: '37/100'))],
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

  void openChallenge(BuildContext context, Challenge challenge) {
    context.push(RouteLocations.getRoute([RouteLocations.campaignChallengesDetail, challenge.id]), extra: challenge);
  }
}
