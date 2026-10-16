import 'package:flutter/material.dart';

class AppRoute<T> extends MaterialPageRoute<T> {
  AppRoute({required WidgetBuilder builder, super.settings})
    : super(
        builder: (BuildContext context) {
          return Material(child: builder(context));
        },
      );
}
