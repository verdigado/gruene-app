import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/prototype/prototype.dart';

/// Runtime switches for the prototype.
///
/// Every flow we explore lives in the same app and on the same technical base;
/// what changes between demos is which of them is switched on. That is the
/// whole mechanism: an [PrototypeExperiment] per flow, each with a master
/// toggle, optional sub-switches for the decisions inside it, and the screens
/// it contributes to the dev drawer. App code asks `experiment.isOn` instead of
/// `isPrototype`, so a flow can be shown to one stakeholder and hidden from the
/// next without a rebuild or a branch.
///
/// Add an experiment in `lib/prototype/experiments.dart`. Nothing else has to
/// know about it — the settings view and the drawer are generated from there.

/// One switch in the settings view.
///
/// Subclasses keep a typed value for call sites ([PrototypeToggle] a bool,
/// [PrototypeChoice] an enum) while exposing an index-based view for the UI, so
/// the settings screen can render any setting without knowing its type.
abstract class PrototypeSetting extends ChangeNotifier {
  PrototypeSetting({required this.id, required this.label, this.description});

  /// Stable key. Used for persistence, so renaming it resets the saved value.
  final String id;
  final String label;
  final String? description;

  /// The experiment this setting belongs to. A sub-switch is only in effect
  /// while its experiment is on; set by [PrototypeExperiment].
  PrototypeToggle? _parent;

  /// What the setting can be, in the order the UI lists them.
  List<String> get optionLabels;

  /// Optional one-liner per option, explaining what it demonstrates.
  List<String?> get optionNotes => List.filled(optionLabels.length, null);

  int get selectedIndex;
  void selectIndex(int index);

  void reset();

  /// Persisted form. `null` means "at its default", which is not stored.
  String? encode();
  void decode(String raw);
}

/// An on/off feature.
class PrototypeToggle extends PrototypeSetting implements ValueListenable<bool> {
  PrototypeToggle({required super.id, required super.label, super.description, this.defaultOn = false})
    : _value = defaultOn;

  final bool defaultOn;
  bool _value;

  @override
  bool get value => _value;

  set value(bool next) {
    if (_value == next) return;
    _value = next;
    notifyListeners();
  }

  /// What app code asks. False outside prototype mode and false while the
  /// surrounding experiment is off, so a single `if (x.isOn)` at the call site
  /// is enough — production behaviour needs no second condition.
  bool get isOn => isPrototype && _value && (_parent?.isOn ?? true);

  void toggle() => value = !value;

  @override
  List<String> get optionLabels => const ['Aus', 'An'];

  @override
  int get selectedIndex => _value ? 1 : 0;

  @override
  void selectIndex(int index) => value = index == 1;

  @override
  void reset() => value = defaultOn;

  @override
  String? encode() => _value == defaultOn ? null : _value.toString();

  @override
  void decode(String raw) => value = raw == 'true';
}

/// A setting with more than two states — typically two designs of the same
/// step, where the choice between them is still open.
class PrototypeChoice<T extends Enum> extends PrototypeSetting implements ValueListenable<T> {
  PrototypeChoice({
    required super.id,
    required super.label,
    super.description,
    required this.values,
    required this.labelOf,
    this.noteOf,
    T? defaultValue,
  }) : assert(values.isNotEmpty, 'a choice needs options'),
       _default = defaultValue ?? values.first,
       _value = defaultValue ?? values.first;

  final List<T> values;
  final String Function(T) labelOf;
  final String? Function(T)? noteOf;
  final T _default;
  T _value;

  @override
  T get value => _value;

  set value(T next) {
    if (_value == next) return;
    _value = next;
    notifyListeners();
  }

  @override
  List<String> get optionLabels => values.map(labelOf).toList();

  @override
  List<String?> get optionNotes => noteOf == null ? super.optionNotes : values.map(noteOf!).toList();

  @override
  int get selectedIndex => values.indexOf(_value);

  @override
  void selectIndex(int index) => value = values[index];

  @override
  void reset() => value = _default;

  @override
  String? encode() => _value == _default ? null : _value.name;

  @override
  void decode(String raw) {
    for (final v in values) {
      if (v.name == raw) {
        value = v;
        return;
      }
    }
  }
}

/// A screen the drawer can jump to. Flows that are not reachable from the app
/// yet — a mail, a deep link, a step in the middle of an onboarding — still
/// need to be shown in a demo.
@immutable
class PrototypeScreen {
  const PrototypeScreen(this.label, this.builder);

  final String label;
  final WidgetBuilder builder;
}

/// One flow we are prototyping: what it is called, what it can be configured
/// to do, and which screens belong to it.
class PrototypeExperiment {
  PrototypeExperiment({
    required this.id,
    required this.label,
    this.description,
    bool defaultOn = true,
    this.settings = const [],
    this.screens = const [],
    this.presentation = false,
  }) : enabled = PrototypeToggle(id: '$id.enabled', label: label, description: description, defaultOn: defaultOn) {
    for (final setting in settings) {
      setting._parent = enabled;
    }
  }

  final String id;
  final String label;

  /// What this flow is about, in one sentence — read by whoever is demoing it.
  final String? description;

  /// Master switch. Off means the flow is invisible: the app behaves as it
  /// does today, which is the comparison every demo needs.
  final PrototypeToggle enabled;

  /// The decisions inside the flow that are still open.
  final List<PrototypeSetting> settings;

  final List<PrototypeScreen> screens;

  /// About how the prototype is shown, not about a flow — e.g. scrolling on a
  /// shared screen. Scenarios leave these alone, so switching demo steps does
  /// not undo them.
  final bool presentation;

  bool get isOn => enabled.isOn;

  List<PrototypeSetting> get allSettings => [enabled, ...settings];
}

/// A saved combination of persona and switches — "show me this one thing".
///
/// Applying a scenario resets everything else, so a demo always starts from a
/// known state rather than from whatever the last demo left behind.
@immutable
class PrototypeScenario {
  const PrototypeScenario({
    required this.label,
    this.description,
    this.personaId,
    this.experiments = const [],
    this.configure,
    this.screens = const [],
  });

  final String label;
  final String? description;

  /// Persona to switch to, by [PrototypePersona.id].
  final String? personaId;

  /// Experiments switched on. Every other experiment is switched off.
  final List<PrototypeExperiment> experiments;

  /// Sub-settings this scenario pins, run after the reset.
  final VoidCallback? configure;

  /// Screens this demo step needs that the app itself does not lead to — an
  /// e-mail, the login screen. Offered in the menu only while this step is
  /// the active one.
  final List<PrototypeScreen> screens;
}

/// The registry. Notifies whenever any setting changes, so a single listener
/// high up in the widget tree keeps the whole app in sync with the drawer.
class PrototypeSettings extends ChangeNotifier {
  PrototypeSettings();

  final List<PrototypeExperiment> experiments = [];
  final List<PrototypeScenario> scenarios = [];

  bool _loaded = false;

  void register({required List<PrototypeExperiment> experiments, List<PrototypeScenario> scenarios = const []}) {
    prototypePersona.addListener(_onChanged);
    for (final experiment in experiments) {
      this.experiments.add(experiment);
      for (final setting in experiment.allSettings) {
        setting.addListener(_onChanged);
      }
    }
    this.scenarios.addAll(scenarios);
  }

  Iterable<PrototypeSetting> get _all => experiments.expand((e) => e.allSettings);

  PrototypeSetting? settingById(String id) => _all.where((s) => s.id == id).firstOrNull;

  void _onChanged() {
    notifyListeners();
    if (_loaded) unawaited(_save());
  }

  void resetAll() {
    for (final setting in _all) {
      setting.reset();
    }
  }

  /// Everything off — the app as it ships today.
  void allOff() {
    for (final experiment in experiments) {
      experiment.enabled.value = false;
    }
  }

  /// The demo step last applied from the menu, by label. Cleared when someone
  /// changes role or switches by hand, because from then on the screen no
  /// longer shows that step.
  String? activeScenario;

  PrototypeScenario? get active => scenarios.where((s) => s.label == activeScenario).firstOrNull;

  void leaveScenario() {
    if (activeScenario == null) return;
    activeScenario = null;
    notifyListeners();
    _save();
  }

  void apply(PrototypeScenario scenario) {
    final kept = {
      for (final e in experiments.where((e) => e.presentation))
        for (final setting in e.allSettings) setting: setting.encode(),
    };
    resetAll();
    for (final experiment in experiments.where((e) => !e.presentation)) {
      experiment.enabled.value = scenario.experiments.contains(experiment);
    }
    kept.forEach((setting, value) => value == null ? setting.reset() : setting.decode(value));
    scenario.configure?.call();
    activeScenario = scenario.label;
    notifyListeners();
    _save();
  }

  /// Persona plus every switch that is not at its default, as the drawer pill
  /// and the settings header show it.
  String get summary {
    final on = experiments.where((e) => e.isOn).map((e) => e.label).toList();
    if (on.isEmpty) return 'Keine Features aktiv';
    return on.join(' · ');
  }

  static const _storageKey = 'prototype.settings';

  /// Stored alongside the switches. Not a setting id — the leading @ keeps it
  /// from ever colliding with one.
  static const _personaKey = '@persona';
  static const _scenarioKey = '@scenario';

  FlutterSecureStorage? get _storage =>
      GetIt.I.isRegistered<FlutterSecureStorage>() ? GetIt.I<FlutterSecureStorage>() : null;

  /// Restores the last configuration. Called once at startup so a hot restart
  /// mid-demo does not silently change what is on screen.
  Future<void> load() async {
    try {
      final raw = await _storage?.read(key: _storageKey);
      if (raw != null && raw.isNotEmpty) {
        final stored = (jsonDecode(raw) as Map<String, dynamic>).cast<String, String>();
        final persona = prototypePersonas.where((p) => p.id == stored[_personaKey]).firstOrNull;
        if (persona != null) prototypePersona.value = persona;
        activeScenario = stored[_scenarioKey];
        stored.forEach((id, value) => settingById(id)?.decode(value));
      }
    } catch (error) {
      debugPrint('PROTOTYPE: could not read settings ($error) — using defaults');
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final stored = <String, String>{_personaKey: prototypePersona.value.id, _scenarioKey: ?activeScenario};
    for (final setting in _all) {
      final value = setting.encode();
      if (value != null) stored[setting.id] = value;
    }
    try {
      await _storage?.write(key: _storageKey, value: jsonEncode(stored));
    } catch (error) {
      debugPrint('PROTOTYPE: could not save settings ($error)');
    }
  }
}

/// The one instance. Filled in `lib/prototype/experiments.dart`.
final prototypeSettings = PrototypeSettings();

/// Persona and switches together — what app code has to rebuild on.
Listenable get prototypeChanges => Listenable.merge([prototypePersona, prototypeSettings]);

/// Rebuilds [builder] whenever the persona or any switch changes.
///
/// Gating in app code goes through this, so toggling a feature takes effect
/// while the app is running — a stakeholder asking "and without it?" gets the
/// answer in the same session, on the same screen.
class PrototypeListener extends StatelessWidget {
  const PrototypeListener({super.key, required this.builder, this.child});

  final Widget Function(BuildContext context, Widget? child) builder;

  /// Subtree that does not depend on the settings, passed through untouched.
  final Widget? child;

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: prototypeChanges, builder: builder, child: child);
}
