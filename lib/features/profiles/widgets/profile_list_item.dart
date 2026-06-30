import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/horizontal_divider.dart';
import 'package:gruene_app/features/profiles/widgets/profile_header.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide ProfileImage;

class ProfileListItem extends StatelessWidget {
  final PublicProfile profile;
  final bool isUser;

  const ProfileListItem({super.key, required this.profile, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final division = profile.memberships.firstOrNull?.division;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () => isUser ? context.push(Routes.profiles.path) : context.pushNested(profile.id, extra: profile),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: ProfileImage(profile: profile),
        title: Text(profile.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (division != null) Text(division.shortDisplayName, maxLines: 1, overflow: TextOverflow.ellipsis),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: profile
                  .displayRoles()
                  .map((role) => Text(role))
                  .withDividers(HorizontalDivider(color: ThemeColors.textDisabled)),
            ),
          ],
        ),
      ),
    );
  }
}
