import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';

enum LocationType { physical, digital, hybrid }

class EventCreateDialog extends StatefulWidget {
  final Calendar calendar;

  const EventCreateDialog({super.key, required this.calendar});

  @override
  State<EventCreateDialog> createState() => _EventCreateDialogState();
}

class _EventCreateDialogState extends State<EventCreateDialog> {
  final formKey = GlobalKey<FormBuilderState>();
  DateTime start = DateTime.now().startOfHour.add(Duration(hours: 2));
  LocationType? locationType = LocationType.physical;
  bool showAvailableSlots = false;
  bool showExternalUrl = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    DateTime initialEnd = start.add(Duration(hours: 2));

    return FormBuilder(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      child: FullScreenDialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 32,
            children: [
              Section(
                children: [
                  Text(t.events.title, style: theme.textTheme.titleLarge),
                  Text(t.events.intro(calendar: widget.calendar.displayName)),
                  FormBuilderTextField(
                    name: 'name',
                    decoration: InputDecoration(labelText: t.events.name),
                    validator: FormBuilderValidators.required(errorText: t.events.nameRequired),
                  ),
                  FormBuilderTextField(
                    name: 'description',
                    decoration: InputDecoration(
                      labelText: '${t.events.description} (${t.common.optional})',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  ),
                ],
              ),

              Section(
                title: t.events.dateAndTime,
                children: [
                  FormBuilderDateTimePicker(
                    name: 'start',
                    initialValue: DateTime.now().startOfHour.add(Duration(hours: 2)),
                    validator: (start) => start?.isBefore(DateTime.now()) == true ? t.events.startRequired : null,
                    onChanged: (start) {
                      setState(() => this.start = start ?? this.start);
                      formKey.currentState?.fields['start']?.validate();
                    },
                    firstDate: DateTime.now(),
                    format: DateFormat(dateTimeFormat),
                    decoration: InputDecoration(labelText: t.events.start, suffixIcon: Icon(Icons.today)),
                  ),
                  FormBuilderDateTimePicker(
                    name: 'end',
                    format: DateFormat(dateTimeFormat),
                    initialDate: initialEnd,
                    initialTime: TimeOfDay(hour: initialEnd.hour, minute: initialEnd.minute),
                    firstDate: start,
                    validator: (end) => end?.isBefore(start) == true ? t.events.endBeforeStart : null,
                    onChanged: (_) => formKey.currentState?.fields['end']?.validate(),
                    decoration: InputDecoration(
                      labelText: '${t.events.end} (${t.common.optional})',
                      suffixIcon: Icon(Icons.today),
                    ),
                  ),
                ],
              ),

              Section(
                title: t.events.location,
                children: [
                  FormBuilderRadioGroup(
                    name: 'locationType',
                    initialValue: locationType,
                    onChanged: (locationType) => setState(() => this.locationType = locationType),
                    options: [
                      FormBuilderFieldOption(value: LocationType.physical, child: Text(t.events.locationType.physical)),
                      FormBuilderFieldOption(value: LocationType.digital, child: Text(t.events.locationType.online)),
                      FormBuilderFieldOption(value: LocationType.hybrid, child: Text(t.events.locationType.hybrid)),
                    ],
                  ),
                  if ([LocationType.physical, LocationType.hybrid].contains(locationType)) ...[
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            name: 'street',
                            decoration: InputDecoration(labelText: t.events.street),
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: FormBuilderTextField(
                            name: 'number',
                            decoration: InputDecoration(labelText: t.events.number),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        SizedBox(
                          width: 96,
                          child: FormBuilderTextField(
                            name: 'zipCode',
                            decoration: InputDecoration(labelText: t.events.zipCode),
                          ),
                        ),
                        Expanded(
                          child: FormBuilderTextField(
                            name: 'city',
                            decoration: InputDecoration(labelText: t.events.city),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if ([LocationType.digital, LocationType.hybrid].contains(locationType))
                    FormBuilderTextField(
                      name: 'link',
                      validator: FormBuilderValidators.url(errorText: t.events.locationUrlRequired),
                      decoration: InputDecoration(labelText: t.events.locationUrl),
                    ),
                ],
              ),

              Section(
                title: t.events.other,
                children: [
                  FormBuilderSwitch(
                    name: 'limitedSlots',
                    title: Text(t.events.limitedSlots),
                    onChanged: (value) {
                      setState(() => showAvailableSlots = value ?? false);
                    },
                  ),
                  if (showAvailableSlots) ...[
                    Text(t.events.availableSlots, style: theme.textTheme.bodyMedium),
                    FormBuilderTextField(name: 'availableSlots'),
                  ],
                  FormBuilderSwitch(
                    name: 'useExternalUrl',
                    title: Text(t.events.useExternalUrl),
                    onChanged: (value) {
                      setState(() => showExternalUrl = value ?? false);
                    },
                  ),
                  if (showExternalUrl) ...[
                    Text(t.events.externalUrl, style: theme.textTheme.bodyMedium),
                    FormBuilderTextField(name: 'externalUrl'),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                height: 64,
                child: FilledButton(
                  // TODO submit
                  onPressed: () => {},
                  child: Text(t.events.create),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final List<Widget> children;
  final String? title;

  const Section({super.key, required this.children, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        if (title != null) Text(title, style: theme.textTheme.titleMedium),
        ...children,
      ],
    );
  }
}
