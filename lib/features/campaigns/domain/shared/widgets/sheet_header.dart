import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

/// Header of a bottom sheet: a title, an optional line below it, and a close button centered on the title line.
///
/// [onClose] defaults to closing the sheet without a result, which fits every sheet whatever its result type.
class SheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  const SheetHeader({super.key, required this.title, this.subtitle, this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // the close button is centered on the title line; its 48 px tap target adds the space above the title
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: theme.textTheme.titleMedium?.apply(color: ThemeColors.text)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: onClose ?? () => Navigator.maybePop(context),
              ),
            ],
          ),
          if (subtitle != null)
            Text(subtitle!, style: theme.textTheme.bodySmall?.apply(color: ThemeColors.textDisabled)),
        ],
      ),
    );
  }
}
