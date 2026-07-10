import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/domain/divisions_api_service.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/app/widgets/hint.dart';
import 'package:gruene_app/features/campaigns/helper/search_action_state.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/widgets/profiles_filter_dialog.dart';
import 'package:gruene_app/features/profiles/widgets/profiles_list.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileSearchScreen extends StatelessWidget {
  final Division? preselectedDivision;

  const ProfileSearchScreen({super.key, this.preselectedDivision});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.profiles.search),
      body: ProfileSearchContainer(preselectedDivision: preselectedDivision),
    );
  }
}

class ProfileSearchContainer extends StatelessWidget {
  final Division? preselectedDivision;
  final SearchActionState Function(PublicProfile profile)? getActionState;

  const ProfileSearchContainer({super.key, this.preselectedDivision, this.getActionState});

  @override
  Widget build(BuildContext context) {
    return FutureLoadingScreen(
      load: () async => (divisions: await loadDivisions(), tags: await fetchProfileTags()),
      buildChild: (data, _) => ProfileSearch(
        divisions: data.divisions,
        tags: data.tags,
        preselectedDivision: preselectedDivision,
        getActionState: getActionState,
      ),
    );
  }
}

class ProfileSearch extends StatefulWidget {
  final List<Division> divisions;
  final List<ProfileTag> tags;
  final Division? preselectedDivision;
  final SearchActionState Function(PublicProfile profile)? getActionState;

  const ProfileSearch({
    super.key,
    required this.divisions,
    required this.tags,
    required this.preselectedDivision,
    this.getActionState,
  });

  @override
  State<ProfileSearch> createState() => _ProfileSearchState();
}

class _ProfileSearchState extends State<ProfileSearch> {
  String _query = '';
  Division? _selectedDivision;
  List<ProfileTag> _selectedSkills = [];
  List<ProfileTag> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _selectedDivision = widget.preselectedDivision;
  }

  @override
  Widget build(BuildContext context) {
    final skills = widget.tags.where((tag) => tag.type == ProfileTagType.skill).toList();
    final interests = widget.tags.where((tag) => tag.type == ProfileTagType.interest).toList();

    final searchFilter = FilterModel(update: (query) => setState(() => _query = query), initial: '', current: _query);
    final divisionFilter = SelectionFilterModel(
      update: (division) => setState(() => _selectedDivision = division),
      initial: null,
      current: _selectedDivision,
      values: widget.divisions,
    );
    final skillsFilter = SelectionFilterModel(
      update: (skills) => setState(() => _selectedSkills = skills),
      initial: <ProfileTag>[],
      current: _selectedSkills,
      values: skills,
    );
    final interestsFilter = SelectionFilterModel(
      update: (interests) => setState(() => _selectedInterests = interests),
      initial: <ProfileTag>[],
      current: _selectedInterests,
      values: interests,
    );

    return Container(
      padding: screenPadding.copyWith(bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          FilterBar(
            searchFilter: searchFilter,
            modified: [divisionFilter, skillsFilter, interestsFilter].modified(),
            filterDialog: ProfilesFilterDialog(
              divisionFilter: divisionFilter,
              skillsFilter: skillsFilter,
              interestsFilter: interestsFilter,
            ),
          ),
          Hint(text: t.profiles.searchHint),
          Expanded(
            child: ProfilesList(
              searchFilter: searchFilter,
              divisionFilter: divisionFilter,
              skillsFilter: skillsFilter,
              interestsFilter: interestsFilter,
              getActionState: widget.getActionState,
            ),
          ),
        ],
      ),
    );
  }
}
