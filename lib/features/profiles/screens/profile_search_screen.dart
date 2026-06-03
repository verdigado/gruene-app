import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/domain/divisions_api_service.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/features/profiles/widgets/profiles_filter_dialog.dart';
import 'package:gruene_app/features/profiles/widgets/profiles_list.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileSearchScreenContainer extends StatelessWidget {
  const ProfileSearchScreenContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.profiles.search),
      body: FutureLoadingScreen(
        load: loadDivisions,
        buildChild: (divisions, _) => ProfileSearchScreen(divisions: divisions),
      ),
    );
  }
}

class ProfileSearchScreen extends StatefulWidget {
  final List<Division> divisions;

  const ProfileSearchScreen({super.key, required this.divisions});

  @override
  State<ProfileSearchScreen> createState() => _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends State<ProfileSearchScreen> {
  String _query = '';
  late Division? _selectedDivision;

  @override
  void initState() {
    super.initState();
    _selectedDivision = null;
  }

  @override
  Widget build(BuildContext context) {
    final searchFilter = FilterModel(update: (query) => setState(() => _query = query), initial: '', current: _query);
    final divisionFilter = SelectionFilterModel(
      update: (divisions) => setState(() => _selectedDivision = divisions),
      initial: null,
      current: _selectedDivision,
      values: widget.divisions,
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
            modified: [divisionFilter].modified(),
            filterDialog: ProfilesFilterDialog(divisionFilter: divisionFilter),
          ),
          Expanded(
            child: ProfilesList(query: searchFilter.current, division: divisionFilter.current),
          ),
        ],
      ),
    );
  }
}
