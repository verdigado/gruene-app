import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/utils/utils.dart';

class SectionCardListItem extends StatelessWidget {
  final String value;
  final String? title;
  final String? url;
  final void Function()? onTap;
  final Widget? trailing;
  final Widget? extraTrailing;

  const SectionCardListItem({
    super.key,
    this.title,
    required this.value,
    this.url,
    this.extraTrailing,
    this.trailing,
    this.onTap,
  });

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
      onTap: onTap ?? (url != null ? () => openUrl(url, context) : null),
      onLongPress: () => Clipboard.setData(ClipboardData(text: url ?? value)),
      trailing: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              extraTrailing,
              trailing ??
                  (url != null || extraTrailing != null
                      ? Icon(Icons.arrow_outward, color: url != null ? theme.primaryColor : theme.disabledColor)
                      : null),
            ].nonNulls.toList(),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Iterable<Widget> children;
  final String? title;

  const SectionCard({super.key, required this.children, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 1), blurRadius: 12)],
        ),
        child: Card(
          color: theme.colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                  ),
                ...children.withDividers(Divider(indent: 16, endIndent: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
