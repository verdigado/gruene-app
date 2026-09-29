import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Which build of the prototype this is.
///
/// The app version does not distinguish our builds — every APK carries the
/// same 2026.6.0 — so reviewing on a phone means guessing whether the thing in
/// your hand is the one just shipped. This is injected at build time:
///
///   flutter build apk --release --flavor development \
///     --dart-define=PROTOTYPE_BUILD="$(git rev-parse --short HEAD) $(date +%d.%m. %H:%M)"
///
/// Unset it falls back to a marker that says so, rather than pretending.
const prototypeBuild = String.fromEnvironment('PROTOTYPE_BUILD', defaultValue: '');

/// App version plus the prototype build, for the foot of the settings screen.
class PrototypeVersion extends StatelessWidget {
  const PrototypeVersion({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final appLine = info == null ? 'App —' : 'App ${info.version} (${info.buildNumber})';
        final prototypeLine = prototypeBuild.isEmpty
            ? 'Prototyp: unbekannter Build (ohne --dart-define gebaut)'
            : 'Prototyp: $prototypeBuild';

        return Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(appLine, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 2),
              SelectableText(
                prototypeLine,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        );
      },
    );
  }
}
