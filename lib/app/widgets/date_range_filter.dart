import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/date_range_picker.dart';
import 'package:gruene_app/app/widgets/section_title.dart';

class DateRangeFilter extends StatelessWidget {
  final void Function(DateTimeRange? dateRange) setDateRange;
  final String title;
  final DateTimeRange? dateRange;
  final DateTime? lastDate;

  const DateRangeFilter({super.key, required this.title, required this.dateRange, required this.setDateRange, this.lastDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: title),
        Container(
          color: theme.colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          child: DateRangePicker(
            setDateRange: setDateRange,
            dateRange: dateRange,
            lastDate: lastDate,
          ),
        ),
      ],
    );
  }
}
