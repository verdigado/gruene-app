import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class LocationServiceDialog extends StatelessWidget {
  const LocationServiceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.location.activateLocationAccess),
      content: Text(t.location.activateLocationAccessSettings),
      actions: [
        TextButton(child: Text(t.common.actions.cancel), onPressed: () => Navigator.of(context).pop(false)),
        TextButton(child: Text(t.common.actions.openSettings), onPressed: () => Navigator.of(context).pop(true)),
      ],
    );
  }
}

class RationaleDialog extends StatelessWidget {
  final String _rationale;

  const RationaleDialog({super.key, required String rationale}) : _rationale = rationale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(t.location.locationPermission),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(_rationale, style: theme.textTheme.bodyLarge),
          Text(t.location.askPermissionsAgain, style: theme.textTheme.bodyLarge),
        ],
      ),
      actions: [
        TextButton(child: Text(t.location.grantPermission), onPressed: () => Navigator.of(context).pop(true)),
        TextButton(child: Text(t.common.actions.cancel), onPressed: () => Navigator.of(context).pop(false)),
      ],
    );
  }
}
