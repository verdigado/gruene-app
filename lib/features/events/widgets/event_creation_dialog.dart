import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/intl.dart';

class EventEditDialog extends StatefulWidget {
  final Calendar calendar;
  final CalendarEvent? event;

  const EventEditDialog({super.key, required this.calendar, required this.event});

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
    DateTime initialEnd = widget.event?.end ?? start.add(Duration(hours: 2));

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
              Section(
                children: [
                  Text(
                    widget.event == null ? t.events.createTitle : t.events.updateTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                  if (widget.event == null) Text(t.events.intro(calendar: widget.calendar.displayName)),
                  FormBuilderTextField(
                    name: 'name',
                    initialValue: widget.event?.title,
                    decoration: InputDecoration(labelText: t.events.name),
                    validator: FormBuilderValidators.required(errorText: t.events.nameRequired),
                  ),
                  FormBuilderTextField(
                    name: 'description',
                    initialValue: widget.event?.description,
                    decoration: InputDecoration(
                      labelText: '${t.events.description} (${t.common.optional})',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  ),
                  FormBuilderTextField(
                    name: 'url',
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

              Section(
                title: t.events.dateAndTime,
                children: [
                  FormBuilderDateTimePicker(
                    name: 'start',
                    initialValue: start,
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
                    initialValue: widget.event?.end,
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
                      name: 'locationAddress',
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
                      name: 'locationUrl',
                      initialValue: widget.event?.locationUrl,
                      validator: FormBuilderValidators.url(errorText: t.events.urlRequired),
                      decoration: InputDecoration(labelText: t.events.locationUrl),
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
                        // TODO submit
                        onPressed: () => {},
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
