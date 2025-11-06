import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

typedef FilterChipStateChangedCallback = void Function(bool state);

class FilterChipModel {
  final String text;
  final bool isEnabled;
  final bool isActive;

  final FilterChipStateChangedCallback? stateChanged;

  const FilterChipModel({required this.text, required this.isEnabled, this.stateChanged, this.isActive = false});
}

class FilterChipCampaign extends StatefulWidget {
  final List<FilterChipModel> filterOptions;
  final Map<String, List<String>>? filterExclusions;

  const FilterChipCampaign(this.filterOptions, {this.filterExclusions, super.key});

  @override
  State<FilterChipCampaign> createState() => _FilterChipCampaignState();
}

class _FilterChipCampaignState extends State<FilterChipCampaign> {
  Set<FilterChipModel> currentActiveFilters = <FilterChipModel>{};

  @override
  void initState() {
    super.initState();

    currentActiveFilters.addAll(widget.filterOptions.where((x) => x.isActive));
  }

  void unselect(String itemLabel) {
    currentActiveFilters.removeWhere((z) => z.text == itemLabel);
  }

  void unselectExclusions(FilterChipModel item) {
    if (widget.filterExclusions != null) {
      widget.filterExclusions?.entries
          .where((x) => x.key == item.text)
          .map((x) => x.value)
          .forEach((v) => v.forEach(unselect));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Wrap(spacing: 15.0, children: widget.filterOptions.map(getFilterChipItem).toList())],
        ),
      ),
    );
  }

  FilterChip getFilterChipItem(FilterChipModel filterItem) {
    return FilterChip(
      label: Text(filterItem.text),
      backgroundColor: ThemeColors.background,
      selectedColor: ThemeColors.primary,
      padding: EdgeInsets.zero,
      side: filterItem.isEnabled
          ? BorderSide(color: ThemeColors.primary, width: 2)
          : BorderSide(color: ThemeColors.textDisabled, width: 1),
      shape: StadiumBorder(),
      selected: currentActiveFilters.contains(filterItem),
      showCheckmark: false,
      labelStyle: TextStyle(color: filterItem.isEnabled ? ChipLabelColor() : ThemeColors.textDisabled),
      onSelected: (bool selected) {
        filterItem.stateChanged!(selected);
        setState(() {
          if (!filterItem.isEnabled) return;
          if (selected) {
            unselectExclusions(filterItem);
            currentActiveFilters.add(filterItem);
          } else {
            currentActiveFilters.remove(filterItem);
          }
        });
      },
    );
  }
}

class ChipLabelColor extends Color implements WidgetStateColor {
  const ChipLabelColor() : super(_default);

  static const int _default = 0xFF000000;

  @override
  Color resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.white; // Selected text color
    }
    return Colors.black; // normal text color
  }
}
