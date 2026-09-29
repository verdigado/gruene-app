import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/prototype/flows/guest/guest_membership.dart';

/// Shown to guests in place of a section they may not use.
///
/// Rough on purpose: a skeleton of the real layout behind a lock, so it is
/// legible what the area would contain without building any of it. The
/// membership call to action is a stub — what is actually offered there, and
/// whether it should be a hard ask at all, is still open.
class MembersTeaser extends StatelessWidget {
  const MembersTeaser({super.key, required this.title, required this.section, required this.skeleton});

  /// Title of the section, so the locked view still wears its own header.
  final String title;
  final String section;
  final TeaserSkeleton skeleton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MainAppBar(title: title),
      body: _content(context, theme),
    );
  }

  Widget _content(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        // The skeleton keeps scrolling disabled — it is scenery, not content.
        Positioned.fill(
          child: IgnorePointer(child: _Skeleton(kind: skeleton)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ThemeColors.background.withValues(alpha: 0.0),
                  ThemeColors.background.withValues(alpha: 0.9),
                  ThemeColors.background,
                ],
                stops: const [0, 0.62, 0.78],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: ThemeColors.grey100, shape: BoxShape.circle),
                  child: Icon(Icons.lock_outline, color: theme.primaryColor),
                ),
                const SizedBox(height: 20),
                Text(
                  'Dieser Bereich ist Parteimitgliedern vorbehalten',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Du kannst beim Wahlkampf mithelfen. $section sehen '
                  'nur Mitglieder.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // PROTOTYPE: stops pitching membership once an application is
                // running — asking someone to apply twice is how the duplicate
                // gets made.
                const BecomeMemberOrPending(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Which layout the skeleton imitates, so each locked area still reads as
/// itself rather than as generic grey boxes.
enum TeaserSkeleton { articles, events, members, tools }

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.kind});
  final TeaserSkeleton kind;

  @override
  Widget build(BuildContext context) => switch (kind) {
    TeaserSkeleton.articles => _articles(),
    TeaserSkeleton.events => _events(),
    TeaserSkeleton.members => _members(),
    TeaserSkeleton.tools => _tools(),
  };

  /// Category tabs over a grid of tool tiles — the shape of the tools overview.
  Widget _tools() => ListView(
    padding: const EdgeInsets.all(16),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      Row(
        children: [
          for (final width in [90.0, 110.0, 80.0]) ...[
            _block(height: 32, width: width, radius: 16),
            const SizedBox(width: 10),
          ],
        ],
      ),
      const SizedBox(height: 20),
      for (var i = 0; i < 4; i++) ...[
        Row(
          children: [
            for (var j = 0; j < 2; j++) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_block(height: 96, radius: 12), const SizedBox(height: 8), _block(height: 14, width: 110)],
                ),
              ),
              if (j == 0) const SizedBox(width: 12),
            ],
          ],
        ),
        const SizedBox(height: 20),
      ],
    ],
  );

  Widget _articles() => ListView(
    padding: const EdgeInsets.all(16),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      _block(height: 48, radius: 24),
      const SizedBox(height: 16),
      for (var i = 0; i < 3; i++) ...[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(height: 160, radius: 8),
            const SizedBox(height: 12),
            _block(height: 18, width: 260),
            const SizedBox(height: 8),
            _block(height: 14, width: 300),
            const SizedBox(height: 8),
            _block(height: 14, width: 180),
          ],
        ),
        const SizedBox(height: 28),
      ],
    ],
  );

  Widget _events() => ListView(
    padding: const EdgeInsets.all(16),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      _block(height: 48, radius: 24),
      const SizedBox(height: 20),
      for (var i = 0; i < 6; i++) ...[
        Row(
          children: [
            _block(height: 56, width: 56, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_block(height: 16, width: 200), const SizedBox(height: 8), _block(height: 12, width: 140)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ],
  );

  Widget _members() => ListView(
    padding: const EdgeInsets.all(16),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      _block(height: 48, radius: 24),
      const SizedBox(height: 20),
      for (var i = 0; i < 7; i++) ...[
        Row(
          children: [
            _block(height: 44, width: 44, radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_block(height: 15, width: 170), const SizedBox(height: 7), _block(height: 11, width: 110)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
      ],
    ],
  );

  Widget _block({required double height, double? width, double radius = 4}) => Container(
    height: height,
    width: width,
    // textLight rather than grey200: the skeleton is the message — it has to
    // read as the shape of the content, not as an empty screen.
    decoration: BoxDecoration(color: ThemeColors.textLight, borderRadius: BorderRadius.circular(radius)),
  );
}

/// Where "Mitglied werden" goes: the party's public membership page.
const becomeMemberUrl = 'https://www.gruene.de/mitglied-werden';

/// The membership call to action, reusable outside the teaser.
class BecomeMemberNotice extends StatelessWidget {
  const BecomeMemberNotice({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(onPressed: () => openUrl(becomeMemberUrl, context), child: const Text('Jetzt Mitglied werden')),
  );
}
