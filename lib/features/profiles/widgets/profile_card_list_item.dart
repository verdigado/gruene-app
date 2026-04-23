import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/utils/open_url.dart';

class ProfileCardListItem extends StatelessWidget {
  final String value;
  final String? title;
  final String? url;

  const ProfileCardListItem({super.key, this.title, required this.value, this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title ?? value;
    final url = this.url;
    return ListTile(
      title: Text(title, style: this.title != null ? theme.textTheme.titleMedium : theme.textTheme.bodyLarge),
      subtitle: this.title != null
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(value, style: theme.textTheme.bodyLarge?.apply(color: theme.colorScheme.primary)),
            )
          : null,
      onTap: () => url != null ? openUrl(url, context) : Clipboard.setData(ClipboardData(text: value)),
      trailing: url != null ? Icon(Icons.arrow_outward, color: theme.primaryColor) : null,
    );
  }
}
