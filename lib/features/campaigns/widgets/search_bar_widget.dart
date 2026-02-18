import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';

typedef OnExecuteSearchCallback = void Function(String searchText);
typedef OnSearchClearedCallback = void Function();

class SearchBarWidget extends StatefulWidget {
  final OnExecuteSearchCallback onExecuteSearch;
  final OnExecuteSearchCallback? onSearchFieldChanged;
  final OnSearchClearedCallback onSearchCleared;
  final String? initialSearchText;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onExecuteSearch,
    this.initialSearchText = '',
    this.onSearchFieldChanged,
    required this.onSearchCleared,
    required this.hintText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  var _showClearSearch = false;

  @override
  void initState() {
    _controller.text = widget.initialSearchText.safe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var foregroundColor = _controller.text.isEmpty ? ThemeColors.textDisabled : ThemeColors.secondary;
    _showClearSearch = _controller.text.isNotEmpty;

    var theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: ThemeColors.background,
        borderRadius: BorderRadius.all(Radius.circular(18)),
        border: Border.all(color: foregroundColor, width: 1),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => widget.onExecuteSearch(_controller.text),
            icon: Icon(Icons.search_outlined, color: foregroundColor),
          ),
          Expanded(
            child: TextFormField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
                alignLabelWithHint: false,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              style: theme.textTheme.labelMedium?.apply(color: foregroundColor, fontSizeDelta: 2),
              onChanged: (value) {
                setState(() {});
                var onSearchFieldChanged = widget.onSearchFieldChanged;
                if (onSearchFieldChanged != null) {
                  onSearchFieldChanged(value);
                }
              },
              onFieldSubmitted: (value) => widget.onExecuteSearch(_controller.text),
            ),
          ),
          _showClearSearch
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _controller.text = '';
                    });
                    widget.onSearchCleared();
                  },
                  icon: Icon(Icons.close_outlined, color: foregroundColor),
                )
              : SizedBox(width: 24),
        ],
      ),
    );
  }
}
