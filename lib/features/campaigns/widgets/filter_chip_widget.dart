import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/features/campaigns/controllers/filter_chip_controller.dart';

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
  final FilterChipController filterController;

  const FilterChipCampaign({
    required this.filterOptions,
    required this.filterController,
    this.filterExclusions,
    super.key,
  });

  @override
  State<FilterChipCampaign> createState() => _FilterChipCampaignState();
}

class _FilterChipCampaignState extends State<FilterChipCampaign> {
  Set<FilterChipModel> currentActiveFilters = <FilterChipModel>{};

  @override
  void initState() {
    currentActiveFilters.addAll(widget.filterOptions.where((x) => x.isActive));
    widget.filterController.addListener(_selectItem);
    logger.d('Active: ${widget.filterController.value}');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _selectItem();
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.filterController.removeListener(_selectItem);
    super.dispose();
  }

  void _unselect(String itemLabel) {
    currentActiveFilters.removeWhere((z) => z.text == itemLabel);
  }

  void _unselectExclusions(FilterChipModel item) {
    if (widget.filterExclusions != null) {
      widget.filterExclusions?.entries
          .where((x) => x.key == item.text)
          .map((x) => x.value)
          .forEach((v) => v.forEach(_unselect));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [SizedBox.shrink(), ...widget.filterOptions.map(_getFilterChipItem), SizedBox.shrink()],
          ),
        ),
      ),
    );
  }

  FilterChip _getFilterChipItem(FilterChipModel filterItem) {
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
      onSelected: (bool selected) => _executeSelection(filterItem, selected),
    );
  }

  void _executeSelection(FilterChipModel filterItem, bool selected) {
    filterItem.stateChanged!(selected);
    setState(() {
      if (!filterItem.isEnabled) return;
      if (selected) {
        _unselectExclusions(filterItem);
        currentActiveFilters.add(filterItem);
      } else {
        currentActiveFilters.remove(filterItem);
      }
    });
  }

  void _selectItem() {
    if (widget.filterController.value == null) return;
    var filterItem = widget.filterOptions.where((f) => f.text == widget.filterController.value).singleOrNull;
    if (filterItem == null) return;
    _executeSelection(filterItem, true);
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
