import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/i18n/translations.g.dart';

enum TimeIndicatorState { upcoming, active, finished }

class ChallengeTimeIndicator extends StatelessWidget {
  final DateTime start;
  final DateTime end;

  const ChallengeTimeIndicator({super.key, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    TimeIndicatorState? state;
    String indicatorText = '';
    if (now.isBetween(DateTimeRange(start: start, end: end))) {
      state = TimeIndicatorState.active;
      indicatorText = t.campaigns.challenges.timeIndicator.activeLabel(hours: end.difference(now).inHours.toString());
    } else if (now.isBetween(DateTimeRange(start: start.subtract(Duration(days: 3)), end: start))) {
      state = TimeIndicatorState.upcoming;
      indicatorText = t.campaigns.challenges.timeIndicator.startingSoon;
    } else if (now.isBefore(start.subtract(Duration(days: 3)))) {
      state = null;
    } else {
      state = TimeIndicatorState.finished;
    }
    if ([TimeIndicatorState.finished, null].contains(state)) {
      return SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(color: ThemeColors.background, borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: switch (state) {
                TimeIndicatorState.upcoming => ThemeColors.sun,
                TimeIndicatorState.active => ThemeColors.textWarning,
                TimeIndicatorState.finished => throw UnimplementedError(),
                null => throw UnimplementedError(),
              },
              border: switch (state) {
                TimeIndicatorState.upcoming => BoxBorder.all(color: ThemeColors.textDark, width: 1),
                TimeIndicatorState.active => null,
                TimeIndicatorState.finished => throw UnimplementedError(),
                null => throw UnimplementedError(),
              },
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(indicatorText, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
