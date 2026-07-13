import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/available_challenges_widget.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/my_challenges_widget.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  bool _loading = true;
  var now = DateTime.now();
  late final List<Challenge> _joinedChallenges = [
    Challenge(
      id: '1',
      title: '100 Haustüren an einem Wochenende',
      description: 'Challenge 1',
      start: now.subtract(Duration(days: 2)),
      end: now.add(Duration(days: 3)),
      status: ChallengeStatus.active,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 2),
      campaignId: '1',
      activities: [
        ChallengeActivityDto(
          id: '1',
          type: ChallengeActivityType.house,
          count: 5,
          createdAt: DateTime(2026, 7, 1),
          updatedAt: DateTime(2026, 7, 2),
        ),
      ],
    ),
    Challenge(
      id: '2',
      title: 'Challenge 2',
      description: 'Challenge 2',
      start: now.subtract(Duration(days: 4)),
      end: now.add(Duration(days: 5)),
      status: ChallengeStatus.active,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 2),
      campaignId: '1',
      activities: [
        ChallengeActivityDto(
          id: '2',
          type: ChallengeActivityType.flyerSpot,
          count: 10,
          createdAt: DateTime(2026, 7, 1),
          updatedAt: DateTime(2026, 7, 2),
        ),
      ],
    ),
    Challenge(
      id: '2',
      title: 'Challenge 2',
      description: 'Challenge 2',
      start: now.add(Duration(days: 2)),
      end: now.add(Duration(days: 5)),
      status: ChallengeStatus.active,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 2),
      campaignId: '1',
      activities: [
        ChallengeActivityDto(
          id: '2',
          type: ChallengeActivityType.flyerSpot,
          count: 10,
          createdAt: DateTime(2026, 7, 1),
          updatedAt: DateTime(2026, 7, 2),
        ),
      ],
    ),
  ];
  late final List<Challenge> _availableChallenges = [
    Challenge(
      id: '1',
      title: 'Challenge 1',
      description: 'Challenge 1',
      start: now.add(Duration(days: 1)),
      end: now.add(Duration(days: 3)),
      status: ChallengeStatus.active,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 2),
      campaignId: '1',
      activities: [
        ChallengeActivityDto(
          id: '1',
          type: ChallengeActivityType.house,
          count: 5,
          createdAt: DateTime(2026, 7, 1),
          updatedAt: DateTime(2026, 7, 2),
        ),
      ],
    ),
    Challenge(
      id: '2',
      title: 'Challenge 2',
      description: 'Challenge 2',
      start: DateTime(2026, 7, 10),
      end: DateTime(2026, 7, 11),
      status: ChallengeStatus.active,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 2),
      campaignId: '1',
      activities: [
        ChallengeActivityDto(
          id: '2',
          type: ChallengeActivityType.flyerSpot,
          count: 10,
          createdAt: DateTime(2026, 7, 1),
          updatedAt: DateTime(2026, 7, 2),
        ),
      ],
    ),
    Challenge(
      id: '3',
      title: 'Challenge 3',
      description: 'Challenge 3',
      start: DateTime(2026, 7, 10),
      end: DateTime(2026, 7, 11),
      status: ChallengeStatus.active,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 2),
      campaignId: '1',
      activities: [
        ChallengeActivityDto(
          id: '3',
          type: ChallengeActivityType.flyerSpot,
          count: 10,
          createdAt: DateTime(2026, 7, 1),
          updatedAt: DateTime(2026, 7, 2),
        ),
      ],
    ),
    Challenge(
      id: '4',
      title: 'Challenge 4',
      description: 'Challenge 4',
      start: DateTime(2026, 7, 10),
      end: DateTime(2026, 7, 11),
      status: ChallengeStatus.active,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 2),
      campaignId: '1',
      activities: [
        ChallengeActivityDto(
          id: '4',
          type: ChallengeActivityType.flyerSpot,
          count: 10,
          createdAt: DateTime(2026, 7, 1),
          updatedAt: DateTime(2026, 7, 2),
        ),
      ],
    ),
    Challenge(
      id: '5',
      title: 'Challenge 5',
      description: 'Challenge 5',
      start: DateTime(2026, 7, 10),
      end: DateTime(2026, 7, 11),
      status: ChallengeStatus.active,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 2),
      campaignId: '1',
      activities: [
        ChallengeActivityDto(
          id: '5',
          type: ChallengeActivityType.flyerSpot,
          count: 10,
          createdAt: DateTime(2026, 7, 1),
          updatedAt: DateTime(2026, 7, 2),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    await Future.delayed(Duration(milliseconds: 500), () {});

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Container(alignment: Alignment.center, child: CircularProgressIndicator()),
      );
    }
    return RefreshIndicator(
      color: ThemeColors.primary,
      backgroundColor: ThemeColors.sun,
      onRefresh: () {
        return Future.delayed(Duration.zero, reload);
      },

      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Row(children: [MyChallengesWidget(joinedChallenges: _joinedChallenges)]),
            SizedBox(height: 20),
            Row(children: [AvailableChallengesWidget(availableChallenges: _availableChallenges)]),
          ],
        ),
      ),
    );
  }

  void reload() {
    _loadData();
  }
}
