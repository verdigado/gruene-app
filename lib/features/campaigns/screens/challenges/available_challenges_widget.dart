import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/features/campaigns/controllers/filter_chip_controller.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_time_indicator.dart';
import 'package:gruene_app/features/campaigns/widgets/filter_chip_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class AvailableChallengesWidget extends StatefulWidget {
  final List<Challenge> availableChallenges;

  const AvailableChallengesWidget({super.key, required this.availableChallenges});

  @override
  State<AvailableChallengesWidget> createState() => _AvailableChallengesWidgetState();
}

class _AvailableChallengesWidgetState extends State<AvailableChallengesWidget> {
  late List<FilterChipModel> flyerFilter;
  final FilterChipController filterController = FilterChipController();

  @override
  void initState() {
    flyerFilter = [
      FilterChipModel(
        text: t.campaigns.door.label,
        isEnabled: true,
        isActive: true,
        // stateChanged: (state) => onRouteLayerStateChanged(state, getMapInfo(MapInfoType.experienceArea)),
      ),
      FilterChipModel(
        text: t.campaigns.poster.label,
        isEnabled: true,
        isActive: true,
        // stateChanged: (state) => onActionAreaLayerStateChanged(state, getMapInfo(MapInfoType.actionArea)),
      ),
      FilterChipModel(
        text: t.campaigns.flyer.label,
        isEnabled: true,
        isActive: true,
        // stateChanged: (state) => onFocusAreaLayerStateChanged(state, getMapInfo(MapInfoType.focusArea)),
      ),
    ];
    super.initState();
  }

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
            children: [
              Text(t.campaigns.challenges.availableChallengeLabel, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
          FilterChipCampaign(
            filterOptions: flyerFilter,
            filterController: filterController,
            spacingOnBeginAndEnd: false,
          ),
          SizedBox(
            width: mediaQuery.size.width - 16 - 8,
            child: Column(
              children: [
                ...widget.availableChallenges.map((challenge) => getAvailableChallengeCard(challenge, context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getAvailableChallengeCard(Challenge challenge, BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => openChallenge(context, challenge),
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [ThemeColors.secondary, ThemeColors.primary],
                    ),
                    // color: ThemeColors.primary,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 25,
                            child: ChallengeTimeIndicator(start: challenge.start, end: challenge.end),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Abgeordnetenhauswahl Berlin 2026',
                            style: Theme.of(context).textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                          ),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            t.campaigns.challenges.actions.join,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: ThemeColors.primary,
                              decoration: TextDecoration.underline,
                            ),
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

  void openChallenge(BuildContext context, Challenge challenge) {
    context.push(RouteLocations.getRoute([RouteLocations.campaignChallengesDetail, challenge.id]), extra: challenge);
  }
}
