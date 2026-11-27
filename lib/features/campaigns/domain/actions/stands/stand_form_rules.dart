import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_entry_formats.dart';
import 'package:gruene_app/i18n/translations.g.dart';

/// Field rules of the stand form, as decided in #1260.
abstract final class StandFormRules {
  static const nameMaxLength = 100;
  static const descriptionMaxLength = 500;
  static const commentMaxLength = 200;

  static const _defaultDuration = 120;
  static const _quarterHour = 15;
  static const _lastQuarterOfDay = 23 * 60 + 45;

  /// People usually record a stand afterwards: the Termin ends now, rounded to the nearest
  /// quarter hour, and lasts two hours. Both times stay on the day of [now].
  static ({DateTime date, TimeOfDay from, TimeOfDay to}) defaultEntryTimes(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    final rounded = ((minutes + _quarterHour ~/ 2) ~/ _quarterHour) * _quarterHour;
    final to = rounded.clamp(_quarterHour, _lastQuarterOfDay);
    final from = (to - _defaultDuration).clamp(0, to);
    return (date: DateUtils.dateOnly(now), from: _timeOfDay(from), to: _timeOfDay(to));
  }

  /// Flyers can only be counted once the Termin has taken place.
  static bool isAfterToday(DateTime date, DateTime now) => DateUtils.dateOnly(date).isAfter(DateUtils.dateOnly(now));

  static DateTime combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  static String? validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return t.campaigns.stand.errors.nameRequired;
    return _validateLength(trimmed, nameMaxLength);
  }

  static String? validateDescription(String description) => _validateLength(description.trim(), descriptionMaxLength);

  static String? validateComment(String comment) => _validateLength(comment.trim(), commentMaxLength);

  /// `Bis` must be after `Von` on the same day; a Termin crossing midnight is not supported.
  static String? validateTimes(TimeOfDay from, TimeOfDay to) =>
      _minutes(to) > _minutes(from) ? null : t.campaigns.stand.errors.toBeforeFrom;

  /// Empty is allowed and counts as 0.
  static String? validateFlyerCount(String flyerCount) {
    final trimmed = flyerCount.trim();
    if (trimmed.isEmpty) return null;
    final count = int.tryParse(trimmed);
    return count == null || count < 0 ? t.campaigns.stand.errors.flyerCount : null;
  }

  /// The first of [otherEntries] whose time overlaps [startAt]–[endAt]; one ending when the other starts does not.
  /// The app prevents overlapping Termine of a stand; the API does not refuse them (decision in #1260).
  static StandEntryModel? findOverlap(DateTime startAt, DateTime endAt, Iterable<StandEntryModel> otherEntries) =>
      otherEntries.where((e) => startAt.isBefore(e.endAt) && e.startAt.isBefore(endAt)).firstOrNull;

  static String overlapMessage(StandEntryModel overlapping) {
    final (:date, :from, :to) = StandEntryFormats.parts(overlapping);
    return t.campaigns.stand.errors.overlap(date: date, from: from, to: to);
  }

  /// No count for a Termin after today; the API stores an empty count as 0.
  static int? flyerCountToSave(String flyerCount, {required bool isAfterToday}) =>
      isAfterToday ? null : int.tryParse(flyerCount.trim()) ?? 0;

  static String? _validateLength(String value, int max) =>
      value.length > max ? t.campaigns.stand.errors.tooLong(max: max) : null;

  static int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static TimeOfDay _timeOfDay(int minutes) => TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
}
