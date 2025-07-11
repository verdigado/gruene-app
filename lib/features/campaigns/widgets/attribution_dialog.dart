import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AttributionDialog extends StatelessWidget {
  const AttributionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final t = context.t;
    return SimpleDialog(
      title: Text(t.campaigns.map.mapData),
      children: [
        AttributionDialogItem(
          icon: Icons.copyright_outlined,
          color: color,
          text: t.campaigns.map.osmContributors,
          onPressed: () {
            launchUrlString('https://www.openstreetmap.org/copyright', mode: LaunchMode.externalApplication);
          },
        ),
        AttributionDialogItem(
          icon: Icons.copyright_outlined,
          color: color,
          text: 'OpenMapTiles',
          onPressed: () {
            launchUrlString('https://openmaptiles.org/', mode: LaunchMode.externalApplication);
          },
        ),
        AttributionDialogItem(
          icon: Icons.copyright_outlined,
          color: color,
          text: 'Natural Earth',
          onPressed: () {
            launchUrlString('https://naturalearthdata.com/', mode: LaunchMode.externalApplication);
          },
        ),
        AttributionDialogItem(
          icon: Icons.copyright_outlined,
          color: color,
          text: 'BÜNDNIS 90/DIE GRÜNEN',
          onPressed: () {
            launchUrlString('https://www.gruene.de/', mode: LaunchMode.externalApplication);
          },
        ),
      ],
    );
  }
}

class AttributionDialogItem extends StatelessWidget {
  const AttributionDialogItem({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24.0, color: color),
          Flexible(
            child: Container(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: Text(text, style: theme.textTheme.bodySmall?.apply(color: color)),
            ),
          ),
        ],
      ),
    );
  }
}
