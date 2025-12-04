import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(Navigator.of(context, rootNavigator: true).context).showSnackBar(SnackBar(content: Text(text)));
}
