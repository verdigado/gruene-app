import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class ProfileCard extends StatelessWidget {
  final PublicProfile profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final role = profile.displayRoles().firstOrNull;
    final imageUrl = profile.image?.thumbnail.url;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => context.push('${Routes.profiles.path}/${profile.id}', extra: profile),
        child: SizedBox(
          width: 128,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : ColoredBox(
                        color: ThemeColors.textDisabled,
                        child: Icon(Icons.person, size: 48, color: theme.colorScheme.surface),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.fullName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (role != null)
                      Text(role, style: theme.textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DivisionProfileCards extends StatelessWidget {
  final Division division;
  final String userId;

  const DivisionProfileCards({super.key, required this.division, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureLoadingScreen(
      load: () => fetchProfiles(division: division, limit: 20),
      buildChild: (profiles, _) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: horizontalScreenPadding,
        child: Row(
          spacing: 8,
          children: profiles
              .where((profile) => profile.userId != userId)
              .map((profile) => ProfileCard(profile: profile))
              .toList(),
        ),
      ),
    );
  }
}
