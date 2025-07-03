import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

class SettingsCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool isExternal;
  final bool isEnabled;
  final void Function()? onPress;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onPress,
    this.isExternal = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 1), blurRadius: 12)],
      ),
      child: Card(
        color: theme.colorScheme.surface,
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          onTap: isEnabled && onPress != null ? onPress : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.apply(color: isEnabled ? ThemeColors.text : ThemeColors.textDisabled),
          ),
          subtitle: Text(subtitle, style: TextStyle(color: isEnabled ? ThemeColors.text : ThemeColors.textDisabled)),
          leading: SizedBox(
            height: 48,
            width: 48,
            child: ClipRRect(borderRadius: BorderRadius.circular(8.0), child: icon),
          ),
          trailing: onPress != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    isExternal ? Icons.open_in_browser_outlined : Icons.chevron_right_outlined,
                    color: theme.disabledColor,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
