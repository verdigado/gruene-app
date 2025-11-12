import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';

class PageInfo extends StatelessWidget {
  final IconData icon;
  final String? text;
  final String? url;

  const PageInfo({super.key, required this.icon, this.text, this.url}) : assert(text != null || url != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = this.url;

    final hostname = Uri.tryParse(url ?? '')?.host;

    return Row(
      spacing: 4,
      children: [
        Icon(icon),
        url != null
            ? InkWell(
                onTap: () => openUrl(url, context),
                child: Text(
                  text ?? hostname ?? url,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ThemeColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : Text(text!),
      ],
    );
  }
}
