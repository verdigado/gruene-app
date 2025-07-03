part of '../mixins.dart';

mixin FocusAreaInfo {
  void showAboutFocusArea(BuildContext context) async {
    final theme = Theme.of(context);
    await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.backgroundSecondary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, color: ThemeColors.textCancel),
              SizedBox(width: 6),
              Text(
                t.campaigns.infoToast.focusAreas_aboutTitle,
                style: theme.textTheme.titleMedium?.apply(color: ThemeColors.textDark),
              ),
            ],
          ),
          content: Text(
            t.campaigns.infoToast.focusAreas_aboutText,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDark, fontSizeDelta: 1),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: Text(
                t.common.actions.close,
                style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textDark, fontWeightDelta: 2),
              ),
            ),
          ],
        );
      },
    );
  }
}
