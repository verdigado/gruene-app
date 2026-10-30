import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestsFilterDialog extends StatefulWidget {
  final SelectionFilterModel<List<Division>, List<Division>> divisionFilter;

  const GuestsFilterDialog({super.key, required this.divisionFilter});

  @override
  State<GuestsFilterDialog> createState() => _GuestsFilterDialogState();
}

// showFullScreenDialog creates a new BuildContext, so the dialog keeps a local copy of the selection to show changes
class _GuestsFilterDialogState extends State<GuestsFilterDialog> {
  late List<Division> _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.divisionFilter.current;
  }

  void _setSelection(List<Division> divisions) {
    widget.divisionFilter.update(divisions);
    setState(() => _selection = divisions);
  }

  @override
  Widget build(BuildContext context) {
    return FilterDialog(
      resetFilters: () => _setSelection(widget.divisionFilter.initial),
      modified: widget.divisionFilter.modified(_selection),
      children: [
        FilterSection(
          title: t.divisions.divisions,
          child: MultiSelection(
            selected: _selection,
            setSelected: _setSelection,
            items: widget.divisionFilter.values,
            compare: (division1, division2) => division1.divisionKey == division2.divisionKey,
            filter: (division, query) => division.matches(query),
            itemAsString: (division) => division.shortDisplayName,
            label: t.divisions.divisions,
          ),
        ),
      ],
    );
  }
}
