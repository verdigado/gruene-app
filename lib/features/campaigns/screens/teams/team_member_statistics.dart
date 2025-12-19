import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/icon.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';

class TeamMemberStatistics extends StatefulWidget {
  final Team currentTeam;

  const TeamMemberStatistics({super.key, required this.currentTeam});

  @override
  State<TeamMemberStatistics> createState() => _TeamMemberStatisticsState();
}

class _TeamMemberStatisticsState extends State<TeamMemberStatistics> {
  bool _loading = true;
  var _selectedPoiType = PoiType.poster;
  late TeamStatistics _teamStatistics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    // await Future.delayed(Duration(milliseconds: 200));
    // TODO #729 remove mock data when getTeamStatistics is working
    await Future<void>.delayed(Duration(milliseconds: 250));
    // var teamsService = GetIt.I<GrueneApiTeamsService>();
    // var team = await teamsService.getTeamStatistics();

    var rand = Random();
    var teamStatistics = TeamStatistics(
      statistics: [
        MemberStatistics(
          name: 'Renate B.',
          division: 'OV Leverkusen Südstadt',
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),
        MemberStatistics(
          name: 'Paul Wunderlich',
          division: 'OV Leverkusen Südstadt',
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),
        MemberStatistics(
          name: 'Wiebke U.',
          division: 'OV Leverkusen Hau',
          status: TeamMembershipStatus.resigned,
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),
        MemberStatistics(
          name: 'Lukas M.',
          division: 'OV Leverkusen Opladen',
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),
        MemberStatistics(
          name: 'Sophie K.',
          division: 'OV Leverkusen Südstadt',
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),
        MemberStatistics(
          name: 'Maximilian Turbulus-Weberlin',
          division: 'OV Leverkusen Schlebusch',
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),
        MemberStatistics(
          name: 'Emma S.',
          division: 'OV Leverkusen Südstadt',
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),

        MemberStatistics(
          name: 'Emma S1.',
          division: 'OV Leverkusen Südstadt',
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),
        MemberStatistics(
          name: 'Emma S2.',
          division: 'OV Leverkusen Südstadt',
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),
        MemberStatistics(
          name: 'Emma S3.',
          division: 'OV Leverkusen Südstadt',
          start: DateTime(2025 - rand.nextInt(20), rand.nextInt(11) + 1, rand.nextInt(27) + 1),
          flyerCount: rand.nextInt(1000),
          posterCount: rand.nextInt(1000),
          openDoorCount: rand.nextInt(1000),
        ),
      ],
    );
    teamStatistics.statistics.shuffle();

    setState(() {
      _loading = false;
      _teamStatistics = teamStatistics;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(padding: EdgeInsets.fromLTRB(24, 24, 24, 6), child: CircularProgressIndicator());
    }
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: boxShadowDecoration,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.campaigns.team.member_statistics, style: theme.textTheme.titleMedium),
                SegmentedButton<PoiType>(
                  style: SegmentedButton.styleFrom(
                    selectedForegroundColor: ThemeColors.background,
                    selectedBackgroundColor: ThemeColors.primary,
                    side: BorderSide(color: ThemeColors.textLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    visualDensity: VisualDensity.compact,
                  ),
                  multiSelectionEnabled: false,
                  segments: _getButtonSegments(),
                  selected: {_selectedPoiType},
                  showSelectedIcon: false,
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedPoiType = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            Column(children: _getMemberStats()),
          ],
        ),
      ),
    );
  }

  List<ButtonSegment<PoiType>> _getButtonSegments() {
    return [
      ButtonSegment(
        value: PoiType.poster,
        icon: CustomIcon(
          path: 'assets/symbols/posters/poster.svg',
          color: _selectedPoiType == PoiType.poster ? ThemeColors.background : ThemeColors.textDark,
          width: 16,
          height: 16,
        ),
      ),
      ButtonSegment(
        value: PoiType.house,
        icon: CustomIcon(
          path: 'assets/symbols/doors/door.svg',
          color: _selectedPoiType == PoiType.house ? ThemeColors.background : ThemeColors.textDark,
          width: 16,
          height: 16,
        ),
      ),
      ButtonSegment(
        value: PoiType.flyerSpot,
        icon: CustomIcon(
          path: 'assets/symbols/flyer/flyer.svg',
          color: _selectedPoiType == PoiType.flyerSpot ? ThemeColors.background : ThemeColors.textDark,
          width: 16,
          height: 16,
        ),
      ),
    ];
  }

  List<Widget> _getMemberStats() {
    var stats = _teamStatistics.statistics;
    stats.sort(_compareStat);

    return stats.indexed.map(_getStatRow).toList();
  }

  int _getCurrentStatValue(MemberStatistics item) {
    switch (_selectedPoiType) {
      case PoiType.flyerSpot:
        return item.flyerCount;
      case PoiType.poster:
        return item.posterCount;
      case PoiType.house:
        return item.openDoorCount;
      case PoiType.swaggerGeneratedUnknown:
        return 0;
    }
  }

  int _compareStat(MemberStatistics a, MemberStatistics b) {
    return _getCurrentStatValue(a).compareTo(_getCurrentStatValue(b)) * -1;
  }

  Widget _getStatRow((int, MemberStatistics) e) {
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
        crossAxisAlignment: CrossAxisAlignment.end,
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
                  Text(item.name, style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textDark)),
                  Text(
                    t.campaigns.team.member_statistics_member_info(
                      division: item.division,
                      date: DateFormat(t.campaigns.poster.date_format).format(item.start),
                    ),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          Text(
            textAlign: TextAlign.end,
            NumberFormat.decimalPattern(t.$meta.locale.languageCode).format(_getCurrentStatValue(item)),
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
    if (item.status == TeamMembershipStatus.resigned) {
      memberItemWidget = Stack(
        children: [
          memberItemWidget,
          Positioned.fill(child: Container(color: ThemeColors.disabledShadow.withAlpha(170))),
        ],
      );
    }
    return memberItemWidget;
  }
}

class TeamStatistics {
  final List<MemberStatistics> statistics;

  TeamStatistics({required this.statistics});
}

class MemberStatistics {
  final String name;
  final int flyerCount;
  final int posterCount;
  final int openDoorCount;
  final TeamMembershipStatus status;
  final String division;
  final DateTime start;

  MemberStatistics({
    required this.name,
    required this.flyerCount,
    required this.posterCount,
    required this.openDoorCount,
    this.status = TeamMembershipStatus.accepted,
    required this.division,
    required this.start,
  });
}
