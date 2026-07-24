import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/gruene_api_challenge_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/campaigns/controllers/filter_chip_controller.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/challenge_helper.dart';
import 'package:gruene_app/features/campaigns/helper/new_page_error_indicator.dart';
import 'package:gruene_app/features/campaigns/helper/paging_helper.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_badge.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_time_indicator.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/my_challenges_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/filter_chip_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  bool _loading = true;
  late List<FilterChipModel> _flyerFilter;
  final List<ChallengeActivityType> challengeActivityFilter = [
    ChallengeActivityType.house,
    ChallengeActivityType.flyerSpot,
    ChallengeActivityType.poster,
  ];
  final FilterChipController _filterController = FilterChipController();
  PagingState<int, Challenge> _pagingState = PagingState();
  final int _pageSize = 20;
  List<Campaign> _knownCampaigns = [];
  List<JoinedChallenge> _joinedChallenges = [];

  @override
  void dispose() {
    super.dispose();
    _filterController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _flyerFilter = [
      FilterChipModel(
        text: t.campaigns.door.label,
        isActive: challengeActivityFilter.contains(ChallengeActivityType.house),
        stateChanged: (state) => addRemoveActivityType(state, ChallengeActivityType.house),
      ),
      FilterChipModel(
        text: t.campaigns.poster.label,
        isActive: challengeActivityFilter.contains(ChallengeActivityType.poster),
        stateChanged: (state) => addRemoveActivityType(state, ChallengeActivityType.poster),
      ),
      FilterChipModel(
        text: t.campaigns.flyer.label,
        isActive: challengeActivityFilter.contains(ChallengeActivityType.flyerSpot),
        stateChanged: (state) => addRemoveActivityType(state, ChallengeActivityType.flyerSpot),
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    var challengeService = GetIt.I<GrueneApiChallengeService>();
    var joinedChallenges = await challengeService.getMyChallenges(
      challengeStatus: CampaignConstants.currentlyOngoingChallengeFilter,
      onlyActiveCampaigns: true,
      sorting: .userDivision,
    );

    var campaignService = GetIt.I<GrueneApiCampaignService>();
    var knownCampaigns = await campaignService.findCampaigns();

    setState(() {
      _loading = false;
      _joinedChallenges = joinedChallenges;
      _knownCampaigns = knownCampaigns;
    });
  }

  void _fetchNextPage() async {
    if (_pagingState.isLoading) return;

    setState(() {
      _pagingState = _pagingState.copyWith(isLoading: true, error: null);
    });

    try {
      final newKey = (_pagingState.keys?.last ?? 0) + 1;
      var challengeService = GetIt.I<GrueneApiChallengeService>();
      final newItems = await challengeService.getChallenges(
        activityTypes: challengeActivityFilter,
        challengeStatus: CampaignConstants.currentlyOngoingChallengeFilter,
        offset: PagingHelper.getOffsetForPage(newKey, _pageSize),
        limit: _pageSize,
      );

      final isLastPage = newItems.isEmpty || newItems.length < _pageSize;

      setState(() {
        _pagingState = _pagingState.copyWith(
          pages: [...?_pagingState.pages, newItems],
          keys: [...?_pagingState.keys, newKey],
          hasNextPage: !isLastPage,
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _pagingState = _pagingState.copyWith(error: error, isLoading: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Container(alignment: Alignment.center, child: CircularProgressIndicator()),
      );
    }

    var challengeFilter = Container(
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
            filterOptions: _flyerFilter,
            filterController: _filterController,
            spacingOnBeginAndEnd: false,
          ),
        ],
      ),
    );
    var pagingChallenges = PagedSliverList<int, Challenge>(
      state: _pagingState,
      fetchNextPage: _fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        noItemsFoundIndicatorBuilder: (context) => Container(
          padding: EdgeInsets.only(left: 16, top: 20, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.campaigns.challenges.no_challenges_found_title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight(700)),
              ),
              SizedBox(height: 12),
              Text(t.campaigns.challenges.no_challenges_found, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
        newPageErrorIndicatorBuilder: (context) => NewPageErrorIndicator(onTap: _fetchNextPage),
        itemBuilder: (context, item, index) => getAvailableChallengeCard(item, context),
      ),
    );
    return RefreshIndicator(
      color: ThemeColors.primary,
      backgroundColor: ThemeColors.sun,
      onRefresh: () {
        return Future.delayed(Duration.zero, reload);
      },

      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Row(
                  children: [MyChallengesWidget(joinedChallenges: _joinedChallenges, knownCampaigns: _knownCampaigns)],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          SliverToBoxAdapter(child: challengeFilter),
          pagingChallenges,
        ],
      ),
    );
  }

  void reload() {
    _loadData();

    setState(() {
      _pagingState = _pagingState.reset();
    });
  }

  void addRemoveActivityType(bool state, ChallengeActivityType activityType) {
    if (state) {
      if (!challengeActivityFilter.contains(activityType)) {
        challengeActivityFilter.add(activityType);
      }
    } else {
      challengeActivityFilter.remove(activityType);
    }
    setState(() {
      _pagingState = _pagingState.reset();
    });
  }

  Widget getAvailableChallengeCard(Challenge challenge, BuildContext context) {
    String challengeCampaignName = challenge.campaignId == null
        ? ' '
        : _knownCampaigns.firstWhereOrNull((c) => c.id == challenge.campaignId)?.name ?? t.common.unknown;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        child: InkWell(
          onTap: () => ChallengeHelper.openChallengeAsChallenge(context, challenge),
          child: SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [ThemeColors.secondary, ThemeColors.primary],
                          ),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        left: 30,
                        child: Transform.scale(
                          scale: 1.5,
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
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                      color: ThemeColors.background,
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
                              challengeCampaignName,
                              style: Theme.of(context).textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              challenge.title,
                              style: Theme.of(context).textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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
                            _joinedChallenges.any((c) => c.id == challenge.id)
                                ? Text(
                                    t.campaigns.challenges.actions.participated,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: ThemeColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ).disable()
                                : GestureDetector(
                                    onTap: () => joinChallenge(challenge),
                                    child: Text(
                                      t.campaigns.challenges.actions.participate,
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: ThemeColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
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
      ),
    );
  }

  Future<void> joinChallenge(Challenge challenge) async {
    var result = await ChallengeHelper.joinChallenge(context, challenge);
    if (result == null) return;
    _loadData();
  }
}
