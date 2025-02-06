import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/selection_list_item.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class SelectionView extends StatelessWidget {
  final void Function(List<String> selectedOptions) setSelectedOptions;
  final String? title;
  final List<String> options;
  final List<String> selectedOptions;
  final void Function()? onMoreOptionsPressed;
  final bool moreOptions;

  const SelectionView({
    super.key,
    required this.setSelectedOptions,
    required this.options,
    required this.selectedOptions,
    this.title,
    this.onMoreOptionsPressed,
    this.moreOptions = false,
  }) : assert(moreOptions == (onMoreOptionsPressed != null));

  void toggleOption(String option) => setSelectedOptions(
        selectedOptions.contains(option)
            ? selectedOptions.where((it) => it != option).toList()
            : [...selectedOptions, option],
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...title != null ? [SectionTitle(title: title!)] : [],
        ...options.map(
          (option) => SelectionListItem(
            toggleSelection: () => toggleOption(option),
            title: option,
            selected: selectedOptions.contains(option),
          ),
        ),
        ...moreOptions ? [TextListItem(onPress: onMoreOptionsPressed!, title: t.news.moreDivisions)] : [],
      ],
    );
  }
}
