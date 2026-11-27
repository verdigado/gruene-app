import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';

/// Looks like a [TextInputField], but opens a picker (e.g. for a date or a time) through [onTap] instead of the keyboard.
class PickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const PickerField({super.key, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              labelStyle: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
              floatingLabelStyle: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDisabled),
            ),
            child: Text(value, style: theme.textTheme.bodyMedium?.apply(color: ThemeColors.text)),
          ),
        ),
      ),
    );
  }
}
