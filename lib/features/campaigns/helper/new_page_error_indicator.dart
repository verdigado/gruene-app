// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/helper/footer_tile.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class NewPageErrorIndicator extends StatelessWidget {
  const NewPageErrorIndicator({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: FooterTile(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(t.error.error_try_again, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Icon(Icons.refresh_outlined, size: 16),
        ],
      ),
    ),
  );
}
