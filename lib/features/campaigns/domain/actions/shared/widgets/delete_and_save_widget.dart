import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';

/// `Eintrag löschen` (or [deleteLabel]) on the left, `Speichern` on the right.
/// Without [onDelete], only `Speichern` is shown, on the right.
class DeleteAndSaveWidget extends StatelessWidget {
  final void Function()? onDelete;
  final void Function() onSave;
  final String? deleteLabel;

  const DeleteAndSaveWidget({super.key, required this.onDelete, required this.onSave, this.deleteLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: onDelete == null ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
      children: [
        // Flexible keeps the natural button size when it fits and lets the labels wrap at large font sizes
        if (onDelete != null)
          Flexible(
            child: Container(
              padding: EdgeInsets.only(right: 20),
              child: ElevatedButton(
                onPressed: onDelete,
                style: ElevatedButton.styleFrom(
                  foregroundColor: ThemeColors.textWarning,
                  backgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    side: BorderSide(color: ThemeColors.textWarning),
                  ),
                ),
                child: Text(
                  deleteLabel ?? t.campaigns.deleteEntry.label,
                  style: theme.textTheme.titleSmall?.apply(color: ThemeColors.textWarning),
                ),
              ),
            ),
          ),
        Flexible(
          child: Container(
            padding: EdgeInsets.only(left: 20),
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                foregroundColor: ThemeColors.background,
                backgroundColor: ThemeColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: BorderSide(color: ThemeColors.primary),
                ),
              ),
              child: Text(
                t.common.actions.save,
                style: theme.textTheme.titleSmall?.apply(color: ThemeColors.background),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
