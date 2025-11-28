import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/theme/theme.dart';

class MultiLineTextInputField extends StatefulWidget {
  final String labelText;
  final String hint;
  final double? width;
  final TextEditingController? textController;
  final Color? borderColor;
  final int maxLength;

  const MultiLineTextInputField({
    required this.labelText,
    required this.hint,
    this.width,
    this.textController,
    this.borderColor,
    this.maxLength = 200,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _MultiLineTextInputFieldState();
}

class _MultiLineTextInputFieldState extends State<MultiLineTextInputField> {
  late TextEditingController _textEditingController;

  @override
  void dispose() {
    if (widget.textController == null) _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.textController != null) {
      _textEditingController = widget.textController!;
    } else {
      _textEditingController = TextEditingController();
    }

    _textEditingController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputBorder = switch (widget.borderColor) {
      (null) => null,
      (_) => Border.all(color: widget.borderColor!, width: 1),
    };
    return Container(
      width: widget.width,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: inputBorder,
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.labelText,
                  style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_textEditingController.text.length}/${widget.maxLength}',
                  style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _textEditingController,
            style: theme.textTheme.bodyMedium?.apply(color: ThemeColors.text),
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            maxLength: widget.maxLength,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: theme.textTheme.labelMedium?.apply(color: ThemeColors.textLight),
              // labelText: widget.hint,
              border: InputBorder.none,
              labelStyle: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
              label: null,
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            buildCounter: (context, {required currentLength, required isFocused, required maxLength}) =>
                SizedBox(height: 0),
          ),
        ],
      ),
    );
  }
}
