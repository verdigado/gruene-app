import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';

class PageInfo extends StatelessWidget {
  final void Function()? onPress;
  final IconData icon;
  final String? text;
  final String? url;

  const PageInfo({super.key, required this.icon, this.text, this.url, this.onPress})
    : assert((text != null || url != null) && (url == null || onPress == null));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = this.url;
    final onPress = this.onPress;
    final onTap = onPress ?? (url != null ? () => openUrl(url, context) : null);

    final hostname = Uri.tryParse(url ?? '')?.host;

    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon),
          Flexible(
            child: Text(
              text ?? hostname ?? url!,
              style: url != null
                  ? theme.textTheme.bodyMedium?.copyWith(
                      color: ThemeColors.primary,
                      decoration: TextDecoration.underline,
                    )
                  : null,
            ),
          ),
          if (onPress != null) Icon(Icons.info_outline, size: 20, color: ThemeColors.text),
        ],
      ),
    );
  }
}
