// ignore_for_file: public_member_api_docs, sort_constructors_first

part of '../converters.dart';

extension JoinedChallengeExtension on JoinedChallenge {
  ChallengeProgressInfo getProgressInfo() {
    var maxActivityCount = activities.fold(0, (prev, current) => prev + current.count.round());
    var currentActivityCount = participations.fold(
      0,
      (prev, current) => prev + current.currentContributionCount.round(),
    );
    return ChallengeProgressInfo(currentActivityCount: currentActivityCount, maxActivityCount: maxActivityCount);
  }
}

extension ChallengeLeaderboardEntryExtension on ChallengeLeaderboardEntry {
  bool isCompleted() {
    return currentActivityCount >= activityTargetCount;
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
