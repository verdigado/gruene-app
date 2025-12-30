part of '../mixins.dart';

mixin InfoBox {
  void showAboutInfoBox(BuildContext context, String title, String content) async {
    final theme = Theme.of(context);
    await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outlined, color: ThemeColors.textCancel),
              SizedBox(width: 6),
              Text(title, style: theme.textTheme.titleMedium?.apply(color: ThemeColors.textDark)),
            ],
          ),
          content: Text(
            content,
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
