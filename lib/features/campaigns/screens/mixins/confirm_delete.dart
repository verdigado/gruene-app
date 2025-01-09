part of '../mixins.dart';

mixin ConfirmDelete {
  void confirmDelete(BuildContext context, void Function() onDeletePressed) async {
    final theme = Theme.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.alertBackground,
          title: Center(
            child: Text(
              '${t.campaigns.deleteEntry.label}?',
              style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
            ),
          ),
          content: Text(
            t.campaigns.deleteEntry.confirmation_dialog,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.apply(
              color: theme.colorScheme.surface,
              fontSizeDelta: 1,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.maybePop(context, false),
              child: Text(
                t.common.actions.cancel,
                style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textCancel),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.maybePop(context, true),
              child: Text(
                t.common.actions.delete,
                style: theme.textTheme.labelLarge?.apply(
                  color: ThemeColors.textWarning,
                  fontWeightDelta: 2,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (shouldDelete ?? false) {
      onDeletePressed();
    }
  }
}
