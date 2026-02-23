import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:motion_toast/motion_toast.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(Navigator.of(context, rootNavigator: true).context).showSnackBar(SnackBar(content: Text(text)));
}

void showToastError(BuildContext context, String text) {
  var theme = Theme.of(context);
  // should remove the focus from a current input and most likely also close an open keyboard
  FocusManager.instance.primaryFocus?.unfocus();
  MotionToast.error(
    displaySideBar: false,
    description: Text(text, style: theme.textTheme.labelMedium!.apply(color: ThemeColors.background)),
  ).show(context);
}

void showToastAsSnack(BuildContext context, String text, {double height = 80, double? width}) {
  var theme = Theme.of(context);
  // to get the current keyboard height, so that the toast is shown above the keyboard, if it is open
  var mediaQuery = MediaQuery.of(context);
  // should remove the focus from a current input and most likely also close an open keyboard
  FocusManager.instance.primaryFocus?.unfocus();
  MotionToast(
    primaryColor: theme.snackBarTheme.backgroundColor ?? Color(0xFF323232),
    width: width ?? mediaQuery.size.width * 0.9,
    height: height,
    displaySideBar: false,
    description: Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: Text(text, style: theme.textTheme.labelMedium!.apply(color: ThemeColors.background)),
    ),
  ).show(context);
}
