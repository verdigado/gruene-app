import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class DateRangeFilter extends StatelessWidget {
  final void Function(DateTimeRange?) setDateRange;
  final DateTimeRange? dateRange;

  const DateRangeFilter({
    super.key,
    required this.setDateRange,
    required this.dateRange,
  });

  Future<void> openDateRangePicker(BuildContext context) async {
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
    );
    setDateRange(newDateRange);
  }

  String formatDate(DateTime? date) => date == null ? '–' : dateFormatter.format(date.toLocal());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(width: 16),
        Text(t.common.dateFrom),
        SizedBox(width: 16),
        TextButton(
          onPressed: () => openDateRangePicker(context),
          style: TextButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceDim,
            side: BorderSide(color: theme.colorScheme.surfaceDim),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(formatDate(dateRange?.start)),
        ),
        SizedBox(width: 16),
        Text(t.common.dateUntil),
        SizedBox(width: 16),
        TextButton(
          onPressed: () => openDateRangePicker(context),
          style: TextButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceDim,
            side: BorderSide(color: theme.colorScheme.surfaceDim),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(formatDate(dateRange?.end)),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}
