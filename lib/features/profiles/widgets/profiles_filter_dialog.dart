import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfilesFilterDialog extends StatefulWidget {
  final SelectionFilterModel<Division?, List<Division>> divisionFilter;
  final SelectionFilterModel<List<ProfileTag>, List<ProfileTag>> skillsFilter;
  final SelectionFilterModel<List<ProfileTag>, List<ProfileTag>> interestsFilter;

  const ProfilesFilterDialog({
    super.key,
    required this.divisionFilter,
    required this.skillsFilter,
    required this.interestsFilter,
  });

  @override
  State<ProfilesFilterDialog> createState() => _ProfilesFilterDialogState();
}

// showFullScreenDialog creates a new BuildContext, such that state updates in the parent do not update widgets in the dialog
// We therefore need a local copy to reflect the state changes here as well
class _ProfilesFilterDialogState extends State<ProfilesFilterDialog> {
  late Division? _localSelectedDivision;
  late List<ProfileTag> _localSelectedSkills;
  late List<ProfileTag> _localSelectedInterests;

  @override
  void initState() {
    super.initState();
    _localSelectedDivision = widget.divisionFilter.current;
    _localSelectedSkills = widget.skillsFilter.current;
    _localSelectedInterests = widget.interestsFilter.current;
  }

  void setDivision(Division? division) {
    widget.divisionFilter.update(division);
    setState(() => _localSelectedDivision = division);
  }

  void setSkills(List<ProfileTag> skills) {
    widget.skillsFilter.update(skills);
    setState(() => _localSelectedSkills = skills);
  }

  void setInterests(List<ProfileTag> interests) {
    widget.interestsFilter.update(interests);
    setState(() => _localSelectedInterests = interests);
  }

  void resetFilters() {
    setDivision(widget.divisionFilter.initial);
    setSkills(widget.skillsFilter.initial);
    setInterests(widget.interestsFilter.initial);
  }

  @override
  Widget build(BuildContext context) {
    final filtersModified =
        widget.divisionFilter.modified(_localSelectedDivision) ||
        widget.skillsFilter.modified(_localSelectedSkills) ||
        widget.interestsFilter.modified(_localSelectedInterests);

    return FilterDialog(
      resetFilters: resetFilters,
      modified: filtersModified,
      children: [
        FilterSection(
          title: t.divisions.division,
          child: Selection(
            selected: _localSelectedDivision,
            setSelected: setDivision,
            items: widget.divisionFilter.values.sortByLevel(),
            compare: (division1, division2) => division1.id == division2.id,
            filter: (division, query) => division.matches(query),
            itemAsString: (division) => division.shortDisplayName,
            hint: t.divisions.searchDivision,
          ),
        ),
        FilterSection(
          title: t.profiles.skills,
          child: MultiSelection(
            selected: _localSelectedSkills,
            setSelected: setSkills,
            items: widget.skillsFilter.values,
            compare: (skill1, skill2) => skill1.id == skill2.id,
            filter: (skill, query) => skill.label.matches(query),
            itemAsString: (skill) => skill.label,
            hint: t.profiles.searchSkills,
          ),
        ),
        FilterSection(
          title: t.profiles.interests,
          child: MultiSelection(
            selected: _localSelectedInterests,
            setSelected: setInterests,
            items: widget.interestsFilter.values,
            compare: (interest1, interest2) => interest1.id == interest2.id,
            filter: (interest, query) => interest.label.matches(query),
            itemAsString: (interest) => interest.label,
            hint: t.profiles.searchInterests,
          ),
        ),
      ],
    );
  }
}
