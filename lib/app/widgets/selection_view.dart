import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/selection_list_item.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class SelectionView<T> extends StatelessWidget {
  final void Function(List<T> selectedOptions) setSelectedOptions;
  final String Function(T option) getLabel;
  final String? title;
  final List<T> options;
  final List<T> selectedOptions;
  final void Function()? onMoreOptionsPressed;
  final bool moreOptions;

  const SelectionView({
    super.key,
    required this.setSelectedOptions,
    required this.getLabel,
    required this.options,
    required this.selectedOptions,
    this.title,
    this.onMoreOptionsPressed,
    this.moreOptions = false,
  }) : assert(moreOptions == (onMoreOptionsPressed != null));

  void toggleOption(T option) => setSelectedOptions(
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
            title: getLabel(option),
            selected: selectedOptions.contains(option),
          ),
        ),
        ...moreOptions ? [TextListItem(onPress: onMoreOptionsPressed!, title: t.news.moreDivisions)] : [],
      ],
    );
  }
}
