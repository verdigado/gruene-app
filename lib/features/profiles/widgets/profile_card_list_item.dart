import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/utils/open_url.dart';

class ProfileCardListItem extends StatelessWidget {
  final String value;
  final String? title;
  final String? url;
  final bool copyOnTap;

  const ProfileCardListItem({super.key, this.title, required this.value, this.url, this.copyOnTap = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title ?? value;
    final url = this.url;
    final copyOnTap = this.copyOnTap ? () => Clipboard.setData(ClipboardData(text: value)) : null;
    final copyIcon = this.copyOnTap
        ? Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Icon(Icons.copy, color: theme.disabledColor)],
          )
        : null;

    return ListTile(
      title: Text(title, style: this.title != null ? theme.textTheme.titleMedium : theme.textTheme.bodyLarge),
      subtitle: this.title != null
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(value, style: theme.textTheme.bodyLarge?.apply(color: theme.colorScheme.primary)),
            )
          : null,
      onTap: url != null ? () => openUrl(url, context) : copyOnTap,
      onLongPress: () => Clipboard.setData(ClipboardData(text: url ?? value)),
      trailing: url != null ? Icon(Icons.arrow_outward, color: theme.primaryColor) : copyIcon,
    );
  }
}
