import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/horizontal_divider.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileListItem extends StatelessWidget {
  final PublicProfile profile;

  const ProfileListItem({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = profile.image?.thumbnail.url;
    final roles = profile.roles.map((role) => role.shortName).toSet().map((role) => Text(role));
    final division = profile.memberships.firstOrNull?.division;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () => context.pushNested(profile.id, extra: profile),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: CircleAvatar(
          backgroundColor: ThemeColors.textDisabled,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null ? Icon(Icons.person, color: theme.colorScheme.surface) : null,
        ),
        title: Text(
          profile.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (division != null) Text(division.shortDisplayName, maxLines: 1, overflow: TextOverflow.ellipsis),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: roles.withDividers(HorizontalDivider(color: ThemeColors.textDisabled)),
            ),
          ],
        ),
      ),
    );
  }
}
