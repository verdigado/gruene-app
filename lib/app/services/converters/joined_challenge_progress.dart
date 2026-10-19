part of '../converters.dart';

extension JoinedChallengeProgress on JoinedChallenge {
  ChallengeProgressInfo getProgressInfo() {
    var maxActivityCount = activities.map((a) => a.count.round()).sum();
    var currentActivityCount = participations
        .map(
          (p) => min(
            p.currentContributionCount.round(),
            activities.firstWhereOrNull((a) => a.type == p.type)?.count.round() ?? 0,
          ),
        )
        .sum();
    return ChallengeProgressInfo(currentActivityCount: currentActivityCount, maxActivityCount: maxActivityCount);
  }

  bool isCompleted() {
    return getProgressInfo().progressValue >= 1.0;
  }
}

class ChallengeProgressInfo {
  final int currentActivityCount;
  final int maxActivityCount;
  late String label;
  late double progressValue;

  ChallengeProgressInfo({required this.currentActivityCount, required this.maxActivityCount}) {
    label = '$currentActivityCount / $maxActivityCount';
    progressValue = maxActivityCount > 0 ? (currentActivityCount / maxActivityCount).clamp(0.0, 1.0) : 0.0;
  }
}
