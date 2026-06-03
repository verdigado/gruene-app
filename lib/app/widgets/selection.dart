import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';

Widget emptyBuilder(_, _) => Container(height: 64, alignment: Alignment.center, child: Text(t.common.noResults));

Widget containerBuilder(_, Widget child) => Padding(padding: screenPadding.copyWith(bottom: 0), child: child);

class Selection<T> extends StatelessWidget {
  final void Function(T? selectedItems) setSelected;
  final bool Function(T item1, T item2) compare;
  final bool Function(T item, String query) filter;
  final String Function(T item) itemAsString;
  final List<T> items;
  final T? selected;
  final String hint;

  const Selection({
    super.key,
    required this.setSelected,
    required this.itemAsString,
    required this.compare,
    required this.filter,
    required this.items,
    required this.selected,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final searchFieldProps = TextFieldProps(decoration: InputDecoration(hintText: hint), autofocus: true);
    final decoratorProps = DropDownDecoratorProps(decoration: InputDecoration(hintText: t.common.actions.select));
    final theme = Theme.of(context);

    return DropdownSearch<T>(
      selectedItem: selected,
      onSelected: setSelected,
      items: (query, _) => items,
      compareFn: compare,
      filterFn: filter,
      itemAsString: itemAsString,
      textProps: TextProps(style: theme.textTheme.bodyLarge),
      popupProps: PopupProps.modalBottomSheet(
        showSearchBox: true,
        searchFieldProps: searchFieldProps,
        containerBuilder: containerBuilder,
        emptyBuilder: emptyBuilder,
      ),
      decoratorProps: decoratorProps,
    );
  }
}

class MultiSelection<T> extends StatelessWidget {
  final void Function(List<T> selectedItems) setSelected;
  final bool Function(T item1, T item2) compare;
  final bool Function(T item, String query) filter;
  final String Function(T item) itemAsString;
  final List<T> items;
  final List<T> selected;
  final String hint;

  const MultiSelection({
    super.key,
    required this.setSelected,
    required this.itemAsString,
    required this.compare,
    required this.filter,
    required this.items,
    required this.selected,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final searchFieldProps = TextFieldProps(decoration: InputDecoration(hintText: hint), autofocus: true);
    final decoratorProps = DropDownDecoratorProps(
      decoration: InputDecoration(
        hintText: t.common.actions.select,
        contentPadding: selected.isNotEmpty ? EdgeInsets.only(left: 4) : null,
      ),
    );

    Widget validationBuilder(BuildContext context, List<T> selectedItems) => Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: ThemeColors.textDisabled)),
      ),
      child: TextButton(
        onPressed: () {
          setSelected(selectedItems);
          Navigator.of(context).pop();
        },
        child: Text(t.common.actions.done),
      ),
    );

    return DropdownSearch<T>.multiSelection(
      selectedItems: selected,
      onSelected: setSelected,
      items: (query, _) => items,
      compareFn: compare,
      filterFn: filter,
      itemAsString: itemAsString,
      selectedItemsWrapProps: WrapProps(spacing: 4, runSpacing: -8),
      popupProps: MultiSelectionPopupProps.modalBottomSheet(
        showSearchBox: true,
        searchFieldProps: searchFieldProps,
        containerBuilder: containerBuilder,
        validationBuilder: validationBuilder,
        emptyBuilder: emptyBuilder,
      ),
      decoratorProps: decoratorProps,
      chipProps: ChipProps(
        labelPadding: EdgeInsets.only(left: 8, right: 0),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
      ),
    );
  }
}
