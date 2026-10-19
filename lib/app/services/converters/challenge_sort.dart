part of '../converters.dart';

enum ChallengeSort { userDivision, endDescending }

extension ChallengeSortQuery on ChallengeSort? {
  String? getSortString() {
    switch (this) {
      case ChallengeSort.userDivision:
        return 'userDivision';
      case ChallengeSort.endDescending:
        return '-endDate';
      case null:
        return null;
    }
  }
}
