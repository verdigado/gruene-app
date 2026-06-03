import 'package:flutter/cupertino.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/widgets/profile_list_item.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfilesList extends StatelessWidget {
  final String query;
  final Division? division;

  const ProfilesList({super.key, required this.query, required this.division});

  @override
  Widget build(BuildContext context) {
    return FutureLoadingScreen(
      load: () => fetchProfiles(query: query, division: division),
      buildChild: (profiles, extra) {
        if (profiles.isEmpty) {
          return ErrorScreen(errorMessage: t.profiles.noResults, retry: extra.refresh);
        }
        return ListView.builder(
          itemCount: profiles.length,
          itemBuilder: (context, index) => ProfileListItem(profile: profiles[index]),
        );
      },
    );
  }
}
