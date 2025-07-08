import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class TextListItem extends StatelessWidget {
  final void Function() onPress;
  final String title;
  final bool isExternal;
  final bool isImplemented;
  final Widget? trailing;

  const TextListItem({
    super.key,
    required this.onPress,
    required this.title,
    this.isExternal = false,
    this.isImplemented = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        enabled: isImplemented,
        onTap: onPress,
        title: Text(
          isImplemented ? title : '$title ${t.settings.notImplemented}',
          style: theme.textTheme.bodyLarge?.apply(color: isImplemented ? ThemeColors.text : ThemeColors.textDisabled),
        ),
        trailing: SizedBox(
          height: 24,
          width: 24,
          child:
              trailing ??
              Icon(
                isExternal ? Icons.open_in_browser_outlined : Icons.chevron_right_outlined,
                color: theme.disabledColor,
              ),
        ),
        tileColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }
}
