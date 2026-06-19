import 'package:flutter/cupertino.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/widgets/profile_list_item.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfilesList extends StatelessWidget {
  final FilterModel<String> searchFilter;
  final SelectionFilterModel<Division?, List<Division>> divisionFilter;
  final SelectionFilterModel<List<ProfileTag>, List<ProfileTag>> skillsFilter;
  final SelectionFilterModel<List<ProfileTag>, List<ProfileTag>> interestsFilter;

  const ProfilesList({
    super.key,
    required this.searchFilter,
    required this.divisionFilter,
    required this.skillsFilter,
    required this.interestsFilter,
  });

  @override
  Widget build(BuildContext context) {
    final tags = [...skillsFilter.current, ...interestsFilter.current];

    return FutureLoadingScreen(
      load: () async => (
        profiles: await fetchProfiles(query: searchFilter.current, division: divisionFilter.current, tags: tags),
        userId: await AuthRepository().getCurrentUserId(),
      ),
      buildChild: (data, extra) {
        if (data.profiles.isEmpty) {
          return ErrorScreen(errorMessage: t.profiles.noResults, retry: extra.refresh);
        }
        return ListView.builder(
          itemCount: data.profiles.length,
          itemBuilder: (context, index) {
            final profile = data.profiles[index];
            return ProfileListItem(profile: profile, isUser: profile.userId == data.userId);
          },
        );
      },
    );
  }
}
