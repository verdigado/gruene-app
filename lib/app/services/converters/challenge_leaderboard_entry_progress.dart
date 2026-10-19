part of '../converters.dart';

extension ChallengeLeaderboardEntryProgress on ChallengeLeaderboardEntry {
  bool isCompleted() {
    return activityProgressCount >= activityTargetCount;
  }
}
