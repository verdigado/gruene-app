import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/membership.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  bool showEndTime = false;
  bool showAvailableSlots = false;
  bool showExternalUrl = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MainAppBar(title: t.events.events),
      body: FutureLoadingScreen(
        load: fetchOwnProfile,
        buildChild: (Profile data, _) {
          final kvMembership = extractKvMembership(data.memberships);

          return FormBuilder(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 68),
              children: [
                Text(t.events.create.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                Text(
                  t.events.create.intro(division: kvMembership!.division.name2),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 28),
                FormBuilderRadioGroup(
                  name: 'locationType',
                  options: [
                    FormBuilderFieldOption(
                      value: 'physical',
                      child: Text(t.events.create.inputs.locationType.options.physical),
                    ),
                    FormBuilderFieldOption(
                      value: 'hybrid',
                      child: Text(t.events.create.inputs.locationType.options.hybrid),
                    ),
                    FormBuilderFieldOption(
                      value: 'online',
                      child: Text(t.events.create.inputs.locationType.options.online),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                FormBuilderTextField(
                  name: 'title',
                  decoration: InputDecoration(labelText: t.events.create.inputs.title.label),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
                const SizedBox(height: 24),
                FormBuilderTextField(
                  name: 'description',
                  decoration: InputDecoration(labelText: t.events.create.inputs.description.label),
                  maxLines: 5,
                ),
                const SizedBox(height: 56),
                Text(t.events.create.dateAndTime, style: theme.textTheme.titleMedium),
                const SizedBox(height: 28),
                FormBuilderDateTimePicker(
                  name: 'start_date',
                  inputType: InputType.date,
                  decoration: InputDecoration(labelText: t.events.create.inputs.start_date.label),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 28),
                FormBuilderDateTimePicker(
                  name: 'start_time',
                  inputType: InputType.time,
                  decoration: InputDecoration(labelText: t.events.create.inputs.start_time.label),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 12),
                FormBuilderSwitch(
                  name: 'show_end_time',
                  title: Text(t.events.create.inputs.show_end_time.label),
                  onChanged: (value) {
                    setState(() {
                      showEndTime = value ?? false;
                    });
                  },
                ),
                if (showEndTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: FormBuilderDateTimePicker(
                      name: 'end_time',
                      inputType: InputType.time,
                      decoration: InputDecoration(labelText: t.events.create.inputs.end_time.label),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                const SizedBox(height: 56),
                Text(t.events.create.location, style: theme.textTheme.titleMedium),
                const SizedBox(height: 28),
                Text(t.events.create.eventLocation, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'street',
                        decoration: InputDecoration(labelText: t.events.create.inputs.street.label),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      width: 64,
                      child: FormBuilderTextField(
                        name: 'streetNumber',
                        decoration: InputDecoration(labelText: t.events.create.inputs.streetNumber.label),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 12),
                      width: 96,
                      child: FormBuilderTextField(
                        name: 'zipCode',
                        decoration: InputDecoration(labelText: t.events.create.inputs.zipCode.label),
                      ),
                    ),
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'city',
                        decoration: InputDecoration(labelText: t.events.create.inputs.city.label),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(t.events.create.link, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                FormBuilderTextField(name: 'link'),
                const SizedBox(height: 84),
                Text(t.events.create.other, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                FormBuilderSwitch(
                  name: 'limited_slots',
                  title: Text(t.events.create.inputs.limitedSlots.label),
                  onChanged: (value) {
                    setState(() {
                      showAvailableSlots = value ?? false;
                    });
                  },
                ),
                if (showAvailableSlots) ...[
                  const SizedBox(height: 8),
                  Text(t.events.create.inputs.availableSlots.label, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  FormBuilderTextField(name: 'available_slots'),
                ],
                const SizedBox(height: 12),
                FormBuilderSwitch(
                  name: 'use_external_url',
                  title: Text(t.events.create.inputs.useExternalUrl.label),
                  onChanged: (value) {
                    setState(() {
                      showExternalUrl = value ?? false;
                    });
                  },
                ),
                if (showExternalUrl) ...[
                  const SizedBox(height: 8),
                  Text(t.events.create.inputs.externalUrl.label, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  FormBuilderTextField(name: 'external_url'),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
