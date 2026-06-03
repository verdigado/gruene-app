import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfilesFilterDialog extends StatefulWidget {
  final SelectionFilterModel<Division?, List<Division>> divisionFilter;

  const ProfilesFilterDialog({super.key, required this.divisionFilter});

  @override
  State<ProfilesFilterDialog> createState() => _ProfilesFilterDialogState();
}

// showFullScreenDialog creates a new BuildContext, such that state updates in the parent do not update widgets in the dialog
// We therefore need a local copy to reflect the state changes here as well
class _ProfilesFilterDialogState extends State<ProfilesFilterDialog> {
  late Division? _localSelectedDivision;

  @override
  void initState() {
    super.initState();
    _localSelectedDivision = widget.divisionFilter.current;
  }

  void setDivision(Division? division) {
    widget.divisionFilter.update(division);
    setState(() => _localSelectedDivision = division);
  }

  void resetFilters() => setDivision(widget.divisionFilter.initial);

  @override
  Widget build(BuildContext context) {
    final filtersModified = widget.divisionFilter.modified(_localSelectedDivision);
    final selected = _localSelectedDivision;

    return FilterDialog(
      resetFilters: resetFilters,
      modified: filtersModified,
      children: [
        FilterSection(
          title: t.divisions.divisions,
          child: Selection<Division>(
            selected: selected,
            setSelected: setDivision,
            items: widget.divisionFilter.values.sortByLevel(),
            compare: (division1, division2) => division1.id == division2.id,
            filter: (division, query) => division.matches(query),
            itemAsString: (division) => division.shortDisplayName,
            hint: t.divisions.searchDivision,
          ),
        ),
      ],
    );
  }
}
