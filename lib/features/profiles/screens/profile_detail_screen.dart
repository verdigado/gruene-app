import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/horizontal_divider.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String profileId;

  const ProfileDetailScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = GoRouterState.of(context).extra as PublicProfile?;

    return Scaffold(
      appBar: MainAppBar(title: t.profiles.profiles),
      body: FutureLoadingScreen<PublicProfile?>(
        load: profile == null ? () => fetchProfile(profileId) : () async => profile,
        buildChild: (profile, extra) {
          if (profile == null) {
            return ErrorScreen(errorMessage: t.profiles.profileNotFound, retry: extra.refresh);
          }
          final imageUrl = profile.image?.thumbnail.url;
          final roles = profile.roles.map((role) => role.shortName).toSet().map((role) => Text(role));
          final division = profile.memberships?.firstOrNull?.division;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                backgroundColor: ThemeColors.textDisabled,
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null ? Icon(Icons.person, color: theme.colorScheme.surface) : null,
              ),
              Text(profile.fullName, style: theme.textTheme.titleMedium),
              if (division != null) Text(division.shortDisplayName, maxLines: 1, overflow: TextOverflow.ellipsis),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: roles.withDividers(HorizontalDivider(color: ThemeColors.textDisabled)),
              ),
            ],
          );
        },
      ),
    );
  }
}
