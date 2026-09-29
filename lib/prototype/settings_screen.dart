import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/prototype/prototype.dart';
import 'package:gruene_app/prototype/settings.dart';
import 'package:gruene_app/prototype/version.dart';

/// The prototype settings view: who the app thinks you are, which experiments
/// are switched on, and how each of them is configured.
///
/// Reachable only from the dev drawer, and only in prototype mode. It is a
/// demo instrument, not a screen of the app — so it is deliberately plain and
/// does not use the app's own components, to make sure nobody in a demo
/// mistakes it for something we are proposing.
class PrototypeSettingsScreen extends StatelessWidget {
  const PrototypeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prototyp-Einstellungen'),
        actions: [
          IconButton(
            tooltip: 'Auf Standard zurücksetzen',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => prototypeSettings.resetAll(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: prototypeChanges,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
          children: [
            // Configuration only. Demo steps live in the menu, so there is one
            // place for presenting and one for adjusting.
            Text(
              'Zum Vorführen die Demo-Schritte im Menü nehmen. Hier lassen sich Rolle '
              'und Schalter einzeln ändern — der gewählte Demo-Schritt gilt dann nicht mehr.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 20),
            _SectionTitle('Rolle', hint: 'Wen die App simuliert. Wechsel startet die Session neu.'),
            ...prototypePersonas.map((p) => _PersonaTile(persona: p)),
            const SizedBox(height: 24),
            _SectionTitle('Features', hint: 'Jedes Experiment einzeln an- und abschaltbar.'),
            ...prototypeSettings.experiments.map((e) => _ExperimentCard(experiment: e)),
            if (prototypeSettings.experiments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Noch keine Experimente registriert — siehe lib/prototype/experiments.dart.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const PrototypeVersion(),
          ],
        ),
      ),
    );
  }
}

/// Switches the simulated user and restarts the session as them.
///
/// The fake token is re-issued on read, so asking the auth bloc to re-check is
/// all it takes — the app then goes through its real startup path.
void applyPersona(BuildContext context, PrototypePersona persona) {
  prototypePersona.value = persona;
  context.read<AuthBloc>().add(CheckTokenRequested());
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.hint});

  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          if (hint != null) Text(hint!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}

class _PersonaTile extends StatelessWidget {
  const _PersonaTile({required this.persona});

  final PrototypePersona persona;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = prototypePersona.value.id == persona.id;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      title: Text(persona.name),
      subtitle: persona.note == null ? null : Text(persona.note!),
      onTap: () {
        prototypeSettings.leaveScenario();
        applyPersona(context, persona);
      },
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({required this.experiment});

  final PrototypeExperiment experiment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final on = experiment.enabled.value;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: on,
            onChanged: (value) {
              prototypeSettings.leaveScenario();
              experiment.enabled.value = value;
            },
            title: Text(experiment.label, style: theme.textTheme.titleSmall),
            subtitle: experiment.description == null ? null : Text(experiment.description!),
          ),
          // Sub-switches stay visible while the experiment is off, greyed out:
          // what a flow can be configured to do is part of explaining it, even
          // before it is switched on.
          if (experiment.settings.isNotEmpty)
            Opacity(
              opacity: on ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !on,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: experiment.settings.map((s) => _SettingTile(setting: s)).toList(),
                  ),
                ),
              ),
            ),
          if (experiment.screens.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Screens', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: experiment.screens
                        .map(
                          (screen) => ActionChip(
                            label: Text(screen.label),
                            onPressed: () =>
                                Navigator.of(context).push(MaterialPageRoute<void>(builder: screen.builder)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Renders any setting from its index-based view: two options become a switch,
/// more than two a radio list.
class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.setting});

  final PrototypeSetting setting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (setting is PrototypeToggle) {
      final toggle = setting as PrototypeToggle;
      return SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        value: toggle.value,
        onChanged: (value) {
          prototypeSettings.leaveScenario();
          toggle.value = value;
        },
        title: Text(toggle.label, style: theme.textTheme.bodyMedium),
        subtitle: toggle.description == null ? null : Text(toggle.description!, style: theme.textTheme.bodySmall),
      );
    }

    final labels = setting.optionLabels;
    final notes = setting.optionNotes;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(setting.label, style: theme.textTheme.bodyMedium),
          if (setting.description != null)
            Text(setting.description!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          for (var i = 0; i < labels.length; i++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                i == setting.selectedIndex ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 20,
                color: i == setting.selectedIndex ? theme.colorScheme.primary : theme.colorScheme.outline,
              ),
              title: Text(labels[i], style: theme.textTheme.bodySmall),
              subtitle: notes[i] == null ? null : Text(notes[i]!, style: theme.textTheme.bodySmall),
              onTap: () {
                prototypeSettings.leaveScenario();
                setting.selectIndex(i);
              },
            ),
        ],
      ),
    );
  }
}
