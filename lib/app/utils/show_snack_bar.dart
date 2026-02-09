import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:motion_toast/motion_toast.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(Navigator.of(context, rootNavigator: true).context).showSnackBar(SnackBar(content: Text(text)));
}

void showToastError(BuildContext context, String text) {
  var theme = Theme.of(context);
  MotionToast.error(
    displaySideBar: false,
    description: Text(text, style: theme.textTheme.labelMedium!.apply(color: ThemeColors.background)),
  ).show(context);
}
