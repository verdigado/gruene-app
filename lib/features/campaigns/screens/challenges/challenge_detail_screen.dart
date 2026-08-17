import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/gruene_api_challenge_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/features/campaigns/helper/challenge_helper.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_badge.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_time_indicator.dart';
import 'package:gruene_app/features/campaigns/screens/progress_with_label.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  bool _loading = true;
  late Challenge _currentChallenge;
  JoinedChallenge? _currentJoinedChallenge;
  late List<ChallengeLeaderboardEntry> _currentChallengeLeaderboard;
  late DateTime _lastLeaderboardUpdate;
  Campaign? _currentCampaign;
  double _lastRankWithTargetReached = -1;

  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      var challengeService = GetIt.I<GrueneApiChallengeService>();
      var results = await Future.wait([
        challengeService.getChallenge(widget.challengeId),
        challengeService.getAllMyChallenges(),
        challengeService.getChallengeLeaderboard(widget.challengeId),
      ]);
      var currentChallenge = results[0] as Challenge;
      var currentJoinedChallenge = (results[1] as List<JoinedChallenge>).firstWhereOrNull(
        (c) => c.id == currentChallenge.id,
      );
      var currentChallengeLeaderboardResult = results[2] as FindChallengeLeaderboardResponse;
      var currentChallengeLeaderboard = currentChallengeLeaderboardResult.data;

      var lastRankWithTargetReached = currentChallengeLeaderboard.where((x) => x.isCompleted()).lastOrNull?.rank ?? -1;
      if (lastRankWithTargetReached == (currentChallengeLeaderboard.lastOrNull?.rank ?? -1)) {
        lastRankWithTargetReached = -1;
      }

      Campaign? currentCampaign;
      if (currentChallenge.campaignId != null) {
        var campaignService = GetIt.I<GrueneApiCampaignService>();
        currentCampaign = await campaignService.getCampaign(currentChallenge.campaignId!);
      }

      if (mounted) {
        setState(() {
          _loading = false;
          _currentChallenge = currentChallenge;
          _currentJoinedChallenge = currentJoinedChallenge;
          _currentChallengeLeaderboard = currentChallengeLeaderboard;
          _lastLeaderboardUpdate = currentChallengeLeaderboardResult.lastUpdate;
          _lastRankWithTargetReached = lastRankWithTargetReached;
          _currentCampaign = currentCampaign;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = MediaQuery.of(context);
    return Scaffold(
      appBar: MainAppBar(title: t.campaigns.challenges.challengeDetail.title, showSettings: false),
      body: Container(
        padding: EdgeInsets.only(bottom: DesignConstants.bottomPadding + 12),
        height: data.size.height,
        width: data.size.width,
        color: ThemeColors.grey200,
        child: _getDetailWidget(),
      ),
    );
  }

  Widget? _getDetailWidget() {
    var data = MediaQuery.of(context);

    if (_loading) {
      return Center(
        child: Container(alignment: Alignment.center, child: CircularProgressIndicator()),
      );
    }
    if (_hasError) {
      return ErrorScreen(errorMessage: t.error.unknownError, retry: () => _loadData());
    }
    String challengeCampaignName = _currentCampaign == null ? ' ' : _currentCampaign?.name ?? t.common.unknown;
    var theme = Theme.of(context);
    return SingleChildScrollView(
      child: Stack(
        children: [
          Stack(
            children: [
              Container(
                height: 128,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [ThemeColors.primary, ThemeColors.secondary],
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 70,
                child: Transform.scale(
                  scale: 2.4,
                  child: Opacity(
                    opacity: 0.2,
                    child: ChallengeBadge(
                      activityType: _currentChallenge.activities.firstOrNull?.type ?? ChallengeActivityType.house,
                      variant: .light,
                      maxActivityCount: _currentChallenge.activities.map((a) => a.count.round()).sum(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 18,
            left: 16,
            child: ChallengeTimeIndicator(start: _currentChallenge.start, end: _currentChallenge.end),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80),
                Text(
                  challengeCampaignName,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: ThemeColors.textDisabled, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                ).withOpacity(0.8),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: ThemeColors.background,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  width: data.size.width - 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [getChallengeBaseInfo(theme), SizedBox(height: 10), getJoinOrProgress()],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: ThemeColors.background,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  width: data.size.width - 32,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
                    child: getChallengeLeaderboardOverview(theme),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getChallengeLeaderboardOverview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.campaigns.challenges.detailScreen.leaderboard.title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          t.campaigns.challenges.detailScreen.leaderboard.version(
            last_udpate: _lastLeaderboardUpdate.getAsLocalDateTimeString(),
          ),
          style: theme.textTheme.labelSmall,
        ).withOpacity(0.8),
        SizedBox(height: 30),
        Column(children: _getChallengeLeaderboard()),
      ],
    );
  }

  Widget getChallengeBaseInfo(ThemeData theme) {
    var activitiesText = _currentChallenge.activities
        .map((activity) => getActivityLabel(activity.type, activity.count.round()))
        .where((x) => x.isNotEmpty)
        .join(', ');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.grey200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentChallenge.title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 26)),
          SizedBox(height: 10),
          Text(
            t.campaigns.challenges.challengeSubTitleLong(
              startDate: _currentChallenge.start.formattedDateTime,
              endDate: _currentChallenge.end.formattedDateTime,
              activities: activitiesText,
              participants: _currentChallenge.participantCount.round(),
            ),
            style: theme.textTheme.labelMedium,
          ).withOpacity(0.8),
          SizedBox(height: 14),
          Text(_currentChallenge.description ?? '', style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget getJoinOrProgress() {
    var theme = Theme.of(context);
    if (_currentJoinedChallenge == null) {
      var media = MediaQuery.of(context);

      return Container(
        width: media.size.width,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: FilledButton(
          onPressed: () => joinChallenge(),
          child: Text(
            t.campaigns.challenges.actions.join,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.surface, fontSize: 15),
          ),
        ),
      );
    } else {
      var progressInfo =
          _currentJoinedChallenge?.getProgressInfo() ??
          ChallengeProgressInfo(currentActivityCount: 0, maxActivityCount: 0);
      var leftOverActivities = _currentChallenge.activities.map(getIncomplete).where((x) => x.rest > 0);
      var leftOverActivitiesLabel = leftOverActivities
          .map((activity) => getActivityLabel(activity.type, activity.rest))
          .join(', ');

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.campaigns.challenges.detailScreen.myProgress,
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                DateTime.now().isBetween(DateTimeRange(start: _currentChallenge.start, end: _currentChallenge.end)) &&
                        leftOverActivities.isNotEmpty
                    ? Container(
                        color: ThemeColors.sun,
                        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                        child: MarkdownBody(
                          data: t.campaigns.challenges.detailScreen.leftOverLabel(
                            timeleft: _currentChallenge.end.getTimeRemaining(),
                            leftover_activities: leftOverActivitiesLabel,
                          ),

                          styleSheet: MarkdownStyleSheet.fromTheme(
                            theme,
                          ).copyWith(p: Theme.of(context).textTheme.labelSmall),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ProgressWithLabel(value: progressInfo.progressValue, label: progressInfo.label),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                onTap: () => leaveChallenge(_currentChallenge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    Icon(Icons.logout_outlined, color: ThemeColors.primary, size: 24),

                    Text(
                      t.campaigns.challenges.actions.leave,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: ThemeColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  LeftOverActivity getIncomplete(ChallengeActivity activity) {
    var targetChallengeActivity = _currentJoinedChallenge?.participations.firstWhereOrNull(
      (a) => a.type == activity.type,
    );
    if (targetChallengeActivity == null) {
      return LeftOverActivity(type: activity.type, rest: 0);
    } else {
      return LeftOverActivity(
        type: activity.type,
        rest: max((activity.count - targetChallengeActivity.currentContributionCount).round(), 0),
      );
    }
  }

  String getActivityLabel(ChallengeActivityType type, int count) {
    var typeLabel = switch (type) {
      ChallengeActivityType.swaggerGeneratedUnknown => null,
      ChallengeActivityType.poster => t.campaigns.poster.label_cardinal(n: count),
      ChallengeActivityType.flyerSpot => t.campaigns.flyer.label_cardinal(n: count),
      ChallengeActivityType.house => t.campaigns.door.label_cardinal(n: count),
    };
    return typeLabel ?? '';
  }

  List<Widget> _getChallengeLeaderboard() {
    if (DateTime.now().isBefore(_currentChallenge.start)) {
      return _getEmptyStatInfo(t.campaigns.challenges.detailScreen.leaderboard.plannedChallengeNotReadyYet);
    } else if (_currentChallengeLeaderboard.isEmpty) {
      return _getEmptyStatInfo(t.campaigns.challenges.detailScreen.leaderboard.leaderboardEmpty);
    } else {
      return _currentChallengeLeaderboard.map(_getLeaderboardRow).toList();
    }
  }

  Widget _getLeaderboardRow(ChallengeLeaderboardEntry challengeLeaderboardEntry) {
    var theme = Theme.of(context);
    var index = challengeLeaderboardEntry.rank.round();
    var item = challengeLeaderboardEntry;

    Widget memberItemWidget = Container(
      padding: .all(4),
      decoration: BoxDecoration(
        border: Border(
          bottom: index == _lastRankWithTargetReached
              ? BorderSide(width: 1, color: ThemeColors.text)
              : BorderSide(width: 0.5, color: ThemeColors.textLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        crossAxisAlignment: .center,
        spacing: 12,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(color: ThemeColors.primary, shape: .circle),
            child: Center(
              child: Text(index.toString(), style: theme.textTheme.displayMedium?.apply(color: ThemeColors.background)),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: .start,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .start,
                  spacing: 6,
                  children: [
                    Flexible(
                      child: Text(
                        item.userName,
                        style: theme.textTheme.labelLarge?.copyWith(fontSize: 18),
                        overflow: .ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    item.isCompleted()
                        ? Container(
                            color: ThemeColors.sun,
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: .end,
                              children: [
                                ...(index == 1
                                    ? [
                                        Text(
                                          t.campaigns.challenges.detailScreen.leaderboard.targetReached,
                                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        SizedBox(width: 5),
                                      ]
                                    : [SizedBox.shrink()]),
                                Icon(Icons.emoji_events_outlined, size: 20),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .start,
                  spacing: 6,
                  children: [
                    Flexible(
                      child: Text(
                        item.divisionName,
                        style: theme.textTheme.labelMedium,
                        overflow: .ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      item.currentActivityCount.round().toString(),
                      textAlign: .end,
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return memberItemWidget;
  }

  List<Widget> _getEmptyStatInfo(String infoText) {
    var mediaQuery = MediaQuery.sizeOf(context);
    var theme = Theme.of(context);
    var myPadding = EdgeInsets.symmetric(vertical: 4);
    var myDecoration = BoxDecoration(borderRadius: BorderRadius.circular(6), color: ThemeColors.primary);
    var memberItemWidgets = [1, 2].map((index) {
      return Container(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: myPadding,
                      child: Container(height: 20, width: mediaQuery.width * 0.4, decoration: myDecoration),
                    ),
                    Container(height: 10, width: mediaQuery.width * 0.3, decoration: myDecoration),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: myPadding,
                  child: Container(height: 20, width: mediaQuery.width * 0.2, decoration: myDecoration),
                ),
              ],
            ),
          ],
        ),
      ).disable(alpha: 220);
    }).toList();

    memberItemWidgets.add(SizedBox(height: 30));
    memberItemWidgets.add(
      Column(
        crossAxisAlignment: .start,
        children: [Text(infoText, style: Theme.of(context).textTheme.labelMedium)],
      ),
    );

    return memberItemWidgets;
  }

  Future<void> leaveChallenge(Challenge currentChallenge) async {
    await ChallengeHelper.leaveChallenge(context, _currentChallenge);
    setState(() {
      _loadData();
    });
  }

  Future<void> joinChallenge() async {
    await ChallengeHelper.joinChallenge(context, _currentChallenge);
    setState(() {
      _loadData();
    });
  }
}

class LeftOverActivity {
  final ChallengeActivityType type;
  final int rest;

  LeftOverActivity({required this.type, required this.rest});
}
