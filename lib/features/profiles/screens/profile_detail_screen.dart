import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/widgets/profile_header.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String profileId;

  const ProfileDetailScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    final profile = GoRouterState.of(context).extra as PublicProfile?;

    return Scaffold(
      appBar: MainAppBar(title: t.profiles.profiles),
      body: FutureLoadingScreen<PublicProfile?>(
        load: profile == null ? () => fetchProfile(profileId) : () async => profile,
        buildChild: (profile, extra) {
          if (profile == null) {
            return ErrorScreen(errorMessage: t.profiles.profileNotFound, retry: extra.refresh);
          }
          return SingleChildScrollView(
            padding: screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                ProfileHeader(profile: profile),
              ],
            ),
          );
        },
      ),
    );
  }
}
