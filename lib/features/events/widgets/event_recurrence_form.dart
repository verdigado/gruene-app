import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/widgets/expansion_list_tile.dart';
import 'package:gruene_app/app/widgets/form_section.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/main.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart';

const recurrenceIntervalField = 'recurrenceInterval';
const recurrenceFrequencyField = 'recurrenceFrequency';
const recurrenceEndTypeField = 'recurrenceEndType';
const recurrenceCountField = 'recurrenceCount';
const recurrenceUntilField = 'recurrenceUntil';

final List<Frequency> supportedFrequencies = [Frequency.daily, Frequency.weekly, Frequency.monthly, Frequency.yearly];
final List<(Frequency?, String)> frequencies = [
  (null, t.events.never),
  (Frequency.daily, t.events.day),
  (Frequency.weekly, t.events.week),
  (Frequency.monthly, t.events.month),
  (Frequency.yearly, t.events.year),
];

final List<(RecurrenceEndType?, String)> recurrenceEndTypes = [
  (null, t.events.never),
  (RecurrenceEndType.until, t.events.atDate),
  (RecurrenceEndType.count, t.events.afterCount),
];

class EventRecurrenceForm extends StatefulWidget {
  final CalendarEvent? event;
  final GlobalKey<FormBuilderState> formKey;

  const EventRecurrenceForm({super.key, required this.event, required this.formKey});

  @override
  State<EventRecurrenceForm> createState() => _EventRecurrenceFormState();
}

class _EventRecurrenceFormState extends State<EventRecurrenceForm> {
  late Frequency? frequency;
  late String? interval;
  late RecurrenceEndType? endType;
  late DateTime? until;
  late String? count;

  @override
  void initState() {
    super.initState();
    final rrule = widget.event?.rrule;
    frequency = supportedFrequencies.contains(rrule?.frequency) ? rrule?.frequency : null;
    interval = (rrule?.interval ?? 1).toString();
    endType = rrule?.recurrenceEndType;
    until = rrule?.until;
    count = rrule?.count?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rrule = frequency != null
        ? RecurrenceRule(
            frequency: frequency!,
            interval: int.tryParse(interval ?? ''),
            until: endType == RecurrenceEndType.until ? until?.copyWith(isUtc: true) : null,
            count: endType == RecurrenceEndType.count ? int.tryParse(count ?? '') : null,
          )
        : null;

    return ExpansionListTile(
      icon: Icon(Icons.edit),
      backgroundColor: theme.colorScheme.surfaceDim,
      iconColor: theme.colorScheme.onSurface,
      titlePadding: EdgeInsetsGeometry.zero,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(Icons.repeat),
          Text(
            rrule?.toText(l10n: rruleL10n, untilDateFormat: DateFormat(dateFormat)) ?? t.events.nonRecurring,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
      children: [
        FormSection(
          title: t.events.recurEvent,
          spacing: 0,
          children: [
            SizedBox(height: 16),
            SpacedVisibility(
              visible: frequency != null,
              child: FormBuilderTextField(
                name: recurrenceIntervalField,
                initialValue: interval,
                onChanged: (interval) => setState(() => this.interval = interval),
                decoration: InputDecoration(labelText: t.events.recurrenceFrequency),
                validator: FormBuilderValidators.positiveNumber(errorText: t.events.positiveNumber),
              ),
            ),
            FormBuilderDropdown(
              name: recurrenceFrequencyField,
              initialValue: frequency,
              style: theme.textTheme.bodyLarge,
              dropdownColor: theme.colorScheme.surface,
              onChanged: (frequency) => setState(() => this.frequency = frequency),
              items: frequencies
                  .map((frequency) => DropdownMenuItem(value: frequency.$1, child: Text(frequency.$2)))
                  .toList(),
            ),
            SizedBox(height: 16),
            SpacedVisibility(
              visible: frequency != null,
              child: FormBuilderDropdown(
                name: recurrenceEndTypeField,
                decoration: InputDecoration(labelText: t.events.recurrenceEnd),
                onChanged: (endType) => setState(() => this.endType = endType),
                initialValue: endType,
                style: theme.textTheme.bodyLarge,
                dropdownColor: theme.colorScheme.surface,
                items: recurrenceEndTypes
                    .map((endType) => DropdownMenuItem(value: endType.$1, child: Text(endType.$2)))
                    .toList(),
              ),
            ),
            SpacedVisibility(
              visible: frequency != null && endType == RecurrenceEndType.until,
              child: FormBuilderDateTimePicker(
                name: recurrenceUntilField,
                inputType: InputType.date,
                initialValue: until,
                onChanged: (until) {
                  setState(() => this.until = until);
                  widget.formKey.currentState?.fields[recurrenceUntilField]?.validate();
                },
                validator: (recurrenceEnd) =>
                    recurrenceEnd?.isBefore(DateTime.now()) == true ? t.events.dateRequired : null,
                firstDate: DateTime.now().add(Duration(days: 1)),
                format: DateFormat(dateFormat),
                decoration: InputDecoration(labelText: t.events.lastDate, suffixIcon: Icon(Icons.today)),
              ),
            ),
            Visibility(
              visible: frequency != null && endType == RecurrenceEndType.count,
              child: FormBuilderTextField(
                name: recurrenceCountField,
                initialValue: count,
                onChanged: (count) => setState(() => this.count = count),
                validator: FormBuilderValidators.positiveNumber(errorText: t.events.positiveNumber),
                decoration: InputDecoration(labelText: t.events.count, helperText: t.events.times),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SpacedVisibility extends StatelessWidget {
  final Widget child;
  final bool visible;

  const SpacedVisibility({super.key, required this.child, required this.visible});

  @override
  Widget build(BuildContext context) => Visibility(
    visible: visible,
    child: Column(children: [child, SizedBox(height: 16)]),
  );
}
