import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

Future<bool> tryAndNotify({
  required Future<dynamic> Function() function,
  required BuildContext context,
  required String successMessage,
  required String errorMessage,
}) async {
  try {
    await function();
    if (context.mounted) {
      showSnackBar(context, successMessage);
    }
    return true;
  } catch (error) {
    if (context.mounted) {
      showSnackBar(context, errorMessage);
    }
  }
  return false;
}
