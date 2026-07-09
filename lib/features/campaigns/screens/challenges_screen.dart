import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  bool _loading = true;
  final List<Challenge> _joinedChallenges = [
    Challenge(
      id: '1',
      title: 'Challenge 1',
      description: 'Challenge 1',
      start: DateTime(2026, 7, 9),
      end: DateTime(2026, 7, 10),
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
  ];
  final List<Challenge> _availableChallenges = [
    Challenge(
      id: '1',
      title: 'Challenge 1',
      description: 'Challenge 1',
      start: DateTime(2026, 7, 9),
      end: DateTime(2026, 7, 10),
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

    await Future.delayed(Duration(seconds: 2), () {});

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
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              MyChallengesWidget(joinedChallenges: _joinedChallenges),
              SizedBox(height: 20),
              Text('Available Challenges', style: Theme.of(context).textTheme.headlineSmall),
              ..._availableChallenges.map(
                (challenge) => ListTile(title: Text(challenge.title), subtitle: Text(challenge.description ?? '')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void reload() {
    _loadData();
  }
}

class MyChallengesWidget extends StatelessWidget {
  final List<Challenge> joinedChallenges;

  MyChallengesWidget({required this.joinedChallenges});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(t.campaigns.challenges.myChallengeLabel, style: Theme.of(context).textTheme.headlineSmall),
        ...joinedChallenges.map(
          (challenge) => ListTile(title: Text(challenge.title), subtitle: Text(challenge.description ?? '')),
        ),
      ],
    );
  }
}
