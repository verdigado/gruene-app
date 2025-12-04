import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/expansion_list_tile.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/selection_list_item.dart';

class SelectionView<T> extends StatelessWidget {
  final void Function(List<T> selectedOptions) setSelectedOptions;
  final String Function(T option) getLabel;
  final String? title;
  final List<T> options;
  final String? moreOptionsTitle;
  final List<T>? moreOptions;
  final List<T> selectedOptions;
  final Color? backgroundColor;

  const SelectionView({
    super.key,
    required this.setSelectedOptions,
    required this.getLabel,
    required this.options,
    required this.selectedOptions,
    this.title,
    this.moreOptions,
    this.moreOptionsTitle,
    this.backgroundColor,
  });

  void toggleOption(T option) => setSelectedOptions(
    selectedOptions.contains(option)
        ? selectedOptions.where((it) => it != option).toList()
        : [...selectedOptions, option],
  );

  List<Widget> renderSelectionListItems(List<T> options) => options
      .map(
        (option) => SelectionListItem(
          toggleSelection: () => toggleOption(option),
          title: getLabel(option),
          selected: selectedOptions.contains(option),
          backgroundColor: backgroundColor,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...title != null ? [SectionTitle(title: title!)] : [],
        ...renderSelectionListItems(options),
        ...moreOptions != null && moreOptions!.isNotEmpty
            ? [ExpansionListTile(titleText: moreOptionsTitle ?? '', children: renderSelectionListItems(moreOptions!))]
            : [],
      ],
    );
  }
}
