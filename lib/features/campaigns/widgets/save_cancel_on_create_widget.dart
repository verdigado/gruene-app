import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class SaveCancelOnCreateWidget extends StatelessWidget {
  final void Function(BuildContext) onSave;

  const SaveCancelOnCreateWidget({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: EdgeInsets.only(right: 6),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.background,
                  foregroundColor: ThemeColors.primary,
                ),
                child: Text(
                  t.common.actions.cancel,
                  style: theme.textTheme.titleMedium?.apply(color: ThemeColors.primary),
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 48,
              padding: EdgeInsets.only(left: 6),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: ThemeColors.background,
                ),
                child: Text(
                  t.common.actions.save,
                  style: theme.textTheme.titleMedium?.apply(color: ThemeColors.background),
                ),
                onPressed: () => onSave(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
