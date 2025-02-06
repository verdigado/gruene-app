import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/widgets/profile_base_data_widget.dart';
import 'package:gruene_app/features/profiles/widgets/profile_header_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class OwnProfileScreen extends StatelessWidget {
  const OwnProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureLoadingScreen(
      load: fetchOwnProfile,
      buildChild: (Profile? data) {
        if (data == null) {
          return ErrorScreen(error: t.profiles.noResult, retry: fetchOwnProfile);
        }
        return ListView(
          children: [
            SizedBox(height: 24),
            ProfileHeaderWidget(profile: data),
            SizedBox(height: 24),
            ProfileBaseDataWidget(profile: data),
          ],
        );
      },
    );
  }
}
