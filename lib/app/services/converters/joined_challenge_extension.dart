// ignore_for_file: public_member_api_docs, sort_constructors_first

part of '../converters.dart';

extension JoinedChallengeExtension on JoinedChallenge {
  ChallengeProgressInfo getProgressInfo() {
    var maxActivityCount = activities.map((a) => a.count.round()).sum();
    var currentActivityCount = participations.map((p) => p.currentContributionCount.round()).sum();
    return ChallengeProgressInfo(currentActivityCount: currentActivityCount, maxActivityCount: maxActivityCount);
  }

  bool isCompleted() {
    return getProgressInfo().progressValue >= 1.0;
  }
}

extension ChallengeLeaderboardEntryExtension on ChallengeLeaderboardEntry {
  bool isCompleted() {
    return currentActivityCount >= activityTargetCount;
  }
}

extension IntListExtension on Iterable<int> {
  int sum() {
    return fold(0, (prev, current) => prev + current.round());
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
