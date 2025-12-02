import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/debouncer.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CustomSearchBar extends StatefulWidget {
  final FilterModel<String> searchFilter;

  const CustomSearchBar({super.key, required this.searchFilter});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final Debouncer _debouncer = Debouncer();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchFilter.selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SearchBar(
      controller: _controller,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (query) => _debouncer.run(() => widget.searchFilter.update(query)),
      leading: Icon(Icons.search_outlined, color: ThemeColors.textDisabled),
      hintText: t.common.search,
      hintStyle: WidgetStatePropertyAll(const TextStyle(color: ThemeColors.textDisabled)),
      trailing: widget.searchFilter.selected.isNotEmpty
          ? [
              IconButton(
                onPressed: () {
                  _controller.clear();
                  widget.searchFilter.reset();
                },
                icon: Icon(Icons.clear, color: ThemeColors.textDisabled),
              ),
            ]
          : [],
      backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
      padding: WidgetStatePropertyAll(EdgeInsets.only(left: 8)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: ThemeColors.textDisabled),
        ),
      ),
      elevation: WidgetStatePropertyAll(0),
    );
  }
}
