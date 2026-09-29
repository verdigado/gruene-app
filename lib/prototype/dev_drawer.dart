import 'package:flutter/material.dart';
import 'package:gruene_app/prototype/prototype.dart';
import 'package:gruene_app/prototype/settings.dart';
import 'package:gruene_app/prototype/settings_screen.dart';

/// Floating control that sits above every screen in prototype mode.
///
/// The panel is the quick lane — scenario, persona, screens — for the things
/// that get tapped during a demo. Everything else lives in
/// [PrototypeSettingsScreen], one tap away.
///
/// The panel renders inside this overlay rather than as a route: the overlay is
/// injected by `MaterialApp.builder`, which sits *above* the Navigator, so
/// pushing a sheet from here would cover the entire app.
class PrototypeOverlay extends StatefulWidget {
  const PrototypeOverlay({super.key, required this.child, required this.navigatorKey});

  final Widget child;

  /// The app's root navigator, used for the jump-to actions.
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<PrototypeOverlay> createState() => _PrototypeOverlayState();
}

class _PrototypeOverlayState extends State<PrototypeOverlay> {
  bool _open = false;

  /// Offset from the bottom-right corner. Draggable because the pill would
  /// otherwise sit on top of whatever the screen underneath puts in that
  /// corner — the map's locate button, for one.
  Offset _pillOffset = const Offset(8, 180);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_open)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _open = false),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),
        if (_open)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _DevPanel(navigatorKey: widget.navigatorKey, onClose: () => setState(() => _open = false)),
          ),
        if (!_open)
          Positioned(
            right: _pillOffset.dx,
            bottom: _pillOffset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                final size = MediaQuery.sizeOf(context);
                setState(() {
                  _pillOffset = Offset(
                    (_pillOffset.dx - details.delta.dx).clamp(0.0, size.width - 96),
                    (_pillOffset.dy - details.delta.dy).clamp(0.0, size.height - 96),
                  );
                });
              },
              child: _DevButton(onTap: () => setState(() => _open = true)),
            ),
          ),
      ],
    );
  }
}

class _DevButton extends StatelessWidget {
  const _DevButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: prototypeChanges,
      builder: (context, _) {
        // The step number is what a presenter needs to glance at; a count of
        // switches meant nothing to anyone.
        final step = prototypeSettings.active?.label.split(' · ').first;
        return Material(
          color: Colors.black.withValues(alpha: 0.78),
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.science_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    step == null
                        ? prototypePersona.value.role.label
                        : 'Schritt $step · ${prototypePersona.value.role.label}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DevPanel extends StatelessWidget {
  const _DevPanel({required this.navigatorKey, required this.onClose});

  final GlobalKey<NavigatorState> navigatorKey;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: ListenableBuilder(
            listenable: prototypeChanges,
            builder: (context, _) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Prototyp', style: theme.textTheme.titleLarge)),
                      IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
                    ],
                  ),
                  Text(
                    'Nur im Prototyp-Modus sichtbar. Nicht Teil der echten App.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 16),
                  // For presenting: the demo steps, and under the active one
                  // the screens it needs. Role and switches are configuration
                  // and live in the settings, so there is one place for each.
                  Text('Demo-Schritt', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final scenario in prototypeSettings.scenarios)
                        ChoiceChip(
                          label: Text(scenario.label),
                          selected: scenario.label == prototypeSettings.activeScenario,
                          onSelected: (_) => _applyScenario(scenario),
                        ),
                    ],
                  ),
                  if (prototypeSettings.active case final active?) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(active.label, style: theme.textTheme.titleSmall),
                          if (active.description != null) ...[
                            const SizedBox(height: 4),
                            Text(active.description!, style: theme.textTheme.bodySmall),
                          ],
                          if (active.screens.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text('Direkt zu', style: theme.textTheme.labelLarge),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [for (final screen in active.screens) _push(screen.label, screen.builder)],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 32),
                  _open(
                    context,
                    label: 'Einstellungen',
                    subtitle: 'Rolle und Schalter einzeln — ${prototypePersona.value.name}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _open(BuildContext context, {required String label, required String subtitle}) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.tune),
      title: Text(label, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        onClose();
        final navigatorContext = navigatorKey.currentContext;
        if (navigatorContext != null) {
          Navigator.of(navigatorContext).push(MaterialPageRoute<void>(builder: (_) => const PrototypeSettingsScreen()));
        }
      },
    );
  }

  Widget _push(String label, WidgetBuilder builder) => ActionChip(
    label: Text(label),
    onPressed: () {
      onClose();
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
      }
    },
  );

  void _applyScenario(PrototypeScenario scenario) {
    prototypeSettings.apply(scenario);
    final persona = prototypePersonas.where((p) => p.id == scenario.personaId).firstOrNull;
    onClose();
    final context = navigatorKey.currentContext;
    if (persona != null && context != null) applyPersona(context, persona);
  }
}
