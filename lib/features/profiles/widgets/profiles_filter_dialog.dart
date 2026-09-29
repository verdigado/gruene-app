import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/prototype/flows/guest/guest_marker.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfilesFilterDialog extends StatefulWidget {
  final SelectionFilterModel<Division?, List<Division>> divisionFilter;
  final SelectionFilterModel<List<ProfileTag>, List<ProfileTag>> skillsFilter;
  final SelectionFilterModel<List<ProfileTag>, List<ProfileTag>> interestsFilter;

  /// PROTOTYPE: only rendered while `guestSearchFilter` is on.
  final SelectionFilterModel<GuestFilterValue, List<GuestFilterValue>> guestFilter;

  const ProfilesFilterDialog({
    super.key,
    required this.divisionFilter,
    required this.skillsFilter,
    required this.interestsFilter,
    required this.guestFilter,
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
  late GuestFilterValue _localSelectedGuests;

  @override
  void initState() {
    super.initState();
    _localSelectedDivision = widget.divisionFilter.current;
    _localSelectedSkills = widget.skillsFilter.current;
    _localSelectedInterests = widget.interestsFilter.current;
    _localSelectedGuests = widget.guestFilter.current;
  }

  void setGuests(GuestFilterValue? value) {
    final selected = value ?? GuestFilterValue.all;
    widget.guestFilter.update(selected);
    setState(() => _localSelectedGuests = selected);
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
    setGuests(widget.guestFilter.initial);
  }

  @override
  Widget build(BuildContext context) {
    final filtersModified =
        widget.divisionFilter.modified(_localSelectedDivision) ||
        widget.skillsFilter.modified(_localSelectedSkills) ||
        widget.interestsFilter.modified(_localSelectedInterests) ||
        (guestSearchFilter.isOn && _localSelectedGuests != GuestFilterValue.all);

    return FilterDialog(
      resetFilters: resetFilters,
      modified: filtersModified,
      children: [
        // PROTOTYPE: first, because it changes the population the other filters
        // then narrow — and because its presence is the question being asked.
        if (guestSearchFilter.isOn)
          FilterSection(
            title: 'Gäste',
            child: Selection(
              selected: _localSelectedGuests,
              setSelected: setGuests,
              items: GuestFilterValue.values,
              compare: (a, b) => a == b,
              filter: (value, query) => value.label.toLowerCase().contains(query.toLowerCase()),
              itemAsString: (value) => value.label,
              label: 'Gäste',
            ),
          ),
        FilterSection(
          title: t.divisions.division,
          child: Selection(
            selected: _localSelectedDivision,
            setSelected: setDivision,
            items: widget.divisionFilter.values.sortByLevel(),
            compare: (division1, division2) => division1.id == division2.id,
            filter: (division, query) => division.matches(query),
            itemAsString: (division) => division.shortDisplayName,
            label: t.divisions.division,
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
            label: t.profiles.skills,
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
            label: t.profiles.interests,
          ),
        ),
      ],
    );
  }
}
