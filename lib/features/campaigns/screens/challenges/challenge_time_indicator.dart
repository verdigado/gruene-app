import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    final locale = LocaleSettings.currentLocale.languageCode;
    timeago.setLocaleMessages(t.campaigns.challenges.timeago.language_code(code: locale), ChallengeTimeMessages());
    if (now.isBetween(DateTimeRange(start: start, end: end))) {
      state = TimeIndicatorState.active;
      indicatorText = t.campaigns.challenges.timeIndicator.activeLabel(
        timeago_label: timeago.format(
          end,
          locale: t.campaigns.challenges.timeago.language_code(code: locale),
          allowFromNow: true,
        ),
      );
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
      decoration: BoxDecoration(
        color: ThemeColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.grey200),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          Text(indicatorText, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class ChallengeTimeMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => t.campaigns.challenges.timeago.prefixAgo;
  @override
  String prefixFromNow() => t.campaigns.challenges.timeago.prefixFromNow;
  @override
  String suffixAgo() => t.campaigns.challenges.timeago.suffixAgo;
  @override
  String suffixFromNow() => t.campaigns.challenges.timeago.suffixFromNow;
  @override
  String lessThanOneMinute(int seconds) => t.campaigns.challenges.timeago.lessThanOneMinute;
  @override
  String aboutAMinute(int minutes) => t.campaigns.challenges.timeago.aboutAMinute;
  @override
  String minutes(int minutes) => t.campaigns.challenges.timeago.minutes(minutes: minutes);
  @override
  String aboutAnHour(int minutes) => t.campaigns.challenges.timeago.aboutAnHour;
  @override
  String hours(int hours) => t.campaigns.challenges.timeago.hours(hours: hours);
  @override
  String aDay(int hours) => t.campaigns.challenges.timeago.aDay;
  @override
  String days(int days) => t.campaigns.challenges.timeago.days(days: days);
  @override
  String aboutAMonth(int days) => t.campaigns.challenges.timeago.aboutAMonth;
  @override
  String months(int months) => t.campaigns.challenges.timeago.months(months: months);
  @override
  String aboutAYear(int year) => t.campaigns.challenges.timeago.aboutAYear;
  @override
  String years(int years) => t.campaigns.challenges.timeago.years(years: years);
  @override
  String wordSeparator() => t.campaigns.challenges.timeago.wordSeparator;
}
