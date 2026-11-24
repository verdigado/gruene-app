import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_entry_formats.dart';

/// Termine of a stand, newest first: when each took place and its flyers.
///
/// The detail shows the latest ones without the year; the full list shows all with the year.
/// Read-only without [onEntryTap]; the stand edit view (#1277) passes it to open a Termin.
class StandEntryList extends StatelessWidget {
  final List<StandEntryModel> entries;
  final bool withYear;
  final void Function(StandEntryModel entry)? onEntryTap;

  const StandEntryList({super.key, required this.entries, required this.withYear, this.onEntryTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.apply(color: ThemeColors.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in StandEntryFormats.newestFirst(entries))
          InkWell(
            onTap: onEntryTap == null ? null : () => onEntryTap!(entry),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                children: [
                  Text(StandEntryFormats.when(entry, withYear: withYear), style: style),
                  Text(StandEntryFormats.flyerCount(entry), style: style),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
