import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/app/widgets/form_section.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/selection_view.dart';
import 'package:gruene_app/features/events/constants/index.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_recurrence_form.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart';

const nameField = 'name';
const descriptionField = 'description';
const urlField = 'url';
const startField = 'start';
const endField = 'end';
const locationTypeField = 'locationType';
const locationAddressField = 'locationAddress';
const locationUrlField = 'locationUrl';
const categoriesField = 'categories';

class EventEditDialog extends StatefulWidget {
  final void Function(CalendarEvent) update;
  final Calendar calendar;
  final CalendarEvent? event;
  final BuildContext context;

  const EventEditDialog({
    super.key,
    required this.calendar,
    required this.event,
    required this.context,
    required this.update,
  });

  @override
  State<EventEditDialog> createState() => _EventEditDialogState();
}

class _EventEditDialogState extends State<EventEditDialog> {
  final formKey = GlobalKey<FormBuilderState>();
  late DateTime start;
  late CalendarEventLocationType? locationType;

  @override
  void initState() {
    super.initState();
    start = widget.event?.start ?? DateTime.now().startOfHour.add(Duration(hours: 2));
    locationType = widget.event?.locationType ?? CalendarEventLocationType.physical;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = widget.event;
    DateTime initialEnd = event?.end ?? start.add(Duration(hours: 2));

    return FormBuilder(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      clearValueOnUnregister: true,
      child: FullScreenDialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 32,
            children: [
              FormSection(
                children: [
                  Text(
                    widget.event == null ? t.events.createTitle : t.events.updateTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                  if (widget.event == null) Text(t.events.intro(calendar: widget.calendar.displayName)),
                  FormBuilderTextField(
                    name: nameField,
                    initialValue: widget.event?.title,
                    decoration: InputDecoration(labelText: t.events.name),
                    validator: FormBuilderValidators.required(errorText: t.events.nameRequired),
                  ),
                  FormBuilderTextField(
                    name: descriptionField,
                    initialValue: widget.event?.description,
                    decoration: InputDecoration(
                      labelText: '${t.events.description} (${t.common.optional})',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  ),
                  FormBuilderTextField(
                    name: urlField,
                    initialValue: widget.event?.url,
                    decoration: InputDecoration(
                      labelText: '${t.events.url} (${t.common.optional})',
                      helperText: t.events.urlHelp,
                      helperMaxLines: 3,
                    ),
                    validator: (url) =>
                        url != null ? FormBuilderValidators.url(errorText: t.events.urlRequired)(url) : null,
                  ),
                ],
              ),

              FormSection(
                title: t.events.dateAndTime,
                children: [
                  FormBuilderDateTimePicker(
                    name: startField,
                    initialValue: start,
                    validator: (start) =>
                        start?.isBefore(DateTime.now()) == true && widget.event == null ? t.events.dateRequired : null,
                    onChanged: (start) {
                      setState(() => this.start = start ?? this.start);
                      formKey.currentState?.fields[startField]?.validate();
                    },
                    firstDate: DateTime.now(),
                    format: DateFormat(dateTimeFormat),
                    decoration: InputDecoration(labelText: t.events.start, suffixIcon: Icon(Icons.today)),
                  ),
                  FormBuilderDateTimePicker(
                    name: endField,
                    format: DateFormat(dateTimeFormat),
                    initialValue: widget.event?.end,
                    initialDate: initialEnd,
                    initialTime: TimeOfDay(hour: initialEnd.hour, minute: initialEnd.minute),
                    firstDate: start,
                    validator: (end) => end?.isBefore(start) == true ? t.events.endBeforeStart : null,
                    onChanged: (_) => formKey.currentState?.fields[endField]?.validate(),
                    decoration: InputDecoration(
                      labelText: '${t.events.end} (${t.common.optional})',
                      suffixIcon: Icon(Icons.today),
                    ),
                  ),
                  EventRecurrenceForm(event: widget.event, formKey: formKey),
                ],
              ),

              FormSection(
                title: t.events.location,
                children: [
                  FormBuilderRadioGroup(
                    name: locationTypeField,
                    initialValue: locationType,
                    onChanged: (locationType) => setState(() => this.locationType = locationType),
                    options: [
                      FormBuilderFieldOption(
                        value: CalendarEventLocationType.physical,
                        child: Text(t.events.locationType.physical),
                      ),
                      FormBuilderFieldOption(
                        value: CalendarEventLocationType.digital,
                        child: Text(t.events.locationType.digital),
                      ),
                      FormBuilderFieldOption(
                        value: CalendarEventLocationType.hybrid,
                        child: Text(t.events.locationType.hybrid),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: [
                      CalendarEventLocationType.physical,
                      CalendarEventLocationType.hybrid,
                    ].contains(locationType),
                    child: FormBuilderTextField(
                      name: locationAddressField,
                      initialValue: widget.event?.locationAddress,
                      validator: FormBuilderValidators.required(),
                      decoration: InputDecoration(labelText: t.events.address),
                    ),
                  ),
                  Visibility(
                    visible: [
                      CalendarEventLocationType.digital,
                      CalendarEventLocationType.hybrid,
                    ].contains(locationType),
                    child: FormBuilderTextField(
                      name: locationUrlField,
                      initialValue: widget.event?.locationUrl,
                      validator: FormBuilderValidators.url(errorText: t.events.urlRequired),
                      decoration: InputDecoration(labelText: t.events.locationUrl),
                    ),
                  ),
                ],
              ),

              FormSection(
                title: t.events.categories,
                children: [
                  FormBuilderField(
                    name: categoriesField,
                    initialValue: widget.event?.categories
                        .where((category) => eventCategories.contains(category))
                        .toList(),
                    builder: (FormFieldState<List<String>> field) => SelectionView(
                      setSelectedOptions: (categories) => field.didChange(categories),
                      options: eventCategories,
                      selectedOptions: field.value ?? <String>[],
                      getLabel: (category) => category,
                      backgroundColor: theme.colorScheme.surfaceDim,
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                height: 64,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 24,
                  children: [
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(
                        t.common.actions.cancel,
                        style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.primary),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          if (formKey.currentState?.saveAndValidate() == true) {
                            final existingEvent = widget.event;
                            final state = formKey.currentState!;
                            final title = state.value[nameField] as String;
                            final description = state.value[descriptionField] as String?;
                            final url = state.value[urlField] as String?;
                            final start = state.value[startField] as DateTime;
                            final end = state.value[endField] as DateTime?;
                            final frequency = state.value[recurrenceFrequencyField] as Frequency?;
                            final interval = state.value[recurrenceIntervalField] as String?;
                            final endType = state.value[recurrenceEndTypeField] as RecurrenceEndType?;
                            final until = state.value[recurrenceUntilField] as DateTime?;
                            final count = state.value[recurrenceCountField] as String?;
                            final locationType = state.value[locationTypeField] as CalendarEventLocationType;
                            final locationAddress = state.value[locationAddressField] as String?;
                            final locationUrl = state.value[locationUrlField] as String?;
                            final categories = state.value[categoriesField] as List<String>?;

                            final rrule = frequency != null
                                ? RecurrenceRule(
                                    frequency: frequency,
                                    interval: int.tryParse(interval ?? ''),
                                    until: endType == RecurrenceEndType.until ? until?.copyWith(isUtc: true) : null,
                                    count: endType == RecurrenceEndType.count ? int.tryParse(count ?? '') : null,
                                  )
                                : null;

                            if (existingEvent == null) {
                              final event = await createEvent(
                                widget.calendar,
                                CreateCalendarEvent(
                                  title: title,
                                  description: description,
                                  url: url,
                                  start: start,
                                  end: end,
                                  locationType: locationType,
                                  locationAddress: locationAddress,
                                  locationUrl: locationUrl,
                                  categories: categories,
                                  recurring: rrule?.toString(),
                                ),
                              );
                              widget.update(event);
                            } else {
                              final event = await updateEvent(
                                widget.calendar,
                                existingEvent,
                                UpdateCalendarEvent(
                                  title: title,
                                  description: description,
                                  url: url,
                                  start: start,
                                  end: end,
                                  locationType: locationType,
                                  locationAddress: locationAddress,
                                  locationUrl: locationUrl,
                                  categories: categories,
                                  recurring: rrule?.toString(),
                                ),
                              );
                              widget.update(event);
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                              showSnackBar(context, event == null ? t.events.created : t.events.updated);
                            }
                          }
                        },
                        child: Text(
                          widget.event == null ? t.events.create : t.events.update,
                          style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
