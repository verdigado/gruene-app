import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/utils.dart';

class ProfileCard extends StatelessWidget {
  final List<Widget> children;
  final String? title;

  const ProfileCard({super.key, required this.children, this.title});

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
