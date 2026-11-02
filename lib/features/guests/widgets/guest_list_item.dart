import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/guests/utils/actions.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestListItem<T> extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<ItemAction<T>> actions;
  final Division division;
  final void Function() onTap;
  final void Function(T changed) onChanged;

  const GuestListItem({
    super.key,
    required this.title,
    required this.children,
    required this.actions,
    required this.division,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      title: Text(title, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(division.shortDisplayName, maxLines: 1, overflow: TextOverflow.ellipsis),
          ...children,
        ],
      ),
      trailing: actions.isNotEmpty
          ? IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => showActions<T>(context: context, actions: actions, onSuccess: onChanged),
            )
          : null,
      contentPadding: actions.isNotEmpty ? EdgeInsets.only(left: horizontalScreenPaddingValue, right: 4) : null,
    );
  }
}
