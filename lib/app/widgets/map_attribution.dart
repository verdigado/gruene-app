import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      bottom: -8,
      right: -8,
      child: IconButton(
        color: theme.disabledColor,
        iconSize: 20,
        icon: const Icon(Icons.info_outlined),
        onPressed: () => showDialog<void>(context: context, builder: (context) => const AttributionDialog()),
      ),
    );
  }
}

class AttributionDialog extends StatelessWidget {
  const AttributionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SimpleDialog(
      title: Text(t.common.map.mapData),
      children: [
        AttributionDialogItem(
          icon: Icons.copyright_outlined,
          text: t.common.map.osmContributors,
          onPressed: () => openUrl('https://www.openstreetmap.org/copyright', context),
        ),
        AttributionDialogItem(
          icon: Icons.copyright_outlined,
          text: 'OpenMapTiles',
          onPressed: () => openUrl('https://openmaptiles.org', context),
        ),
        AttributionDialogItem(
          icon: Icons.copyright_outlined,
          text: 'Natural Earth',
          onPressed: () => openUrl('https://naturalearthdata.com', context),
        ),
        AttributionDialogItem(
          icon: Icons.copyright_outlined,
          text: t.common.party,
          onPressed: () => openUrl(grueneHomeUrl, context),
        ),
      ],
    );
  }
}

class AttributionDialogItem extends StatelessWidget {
  const AttributionDialogItem({super.key, required this.icon, required this.text, required this.onPressed});

  final IconData icon;
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
        spacing: 8,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          Text(text, style: theme.textTheme.bodySmall?.apply(color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}
