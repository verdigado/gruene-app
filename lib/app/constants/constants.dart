import 'package:flutter/material.dart';

const double horizontalScreenPaddingValue = 16;
const EdgeInsets horizontalScreenPadding = EdgeInsets.symmetric(horizontal: horizontalScreenPaddingValue);

const double verticalScreenPaddingValue = 24;
const EdgeInsets verticalScreenPadding = EdgeInsets.symmetric(vertical: verticalScreenPaddingValue);

const EdgeInsets screenPadding = EdgeInsets.symmetric(
  horizontal: horizontalScreenPaddingValue,
  vertical: verticalScreenPaddingValue,
);

EdgeInsets screenPaddingSymmetric({double? horizontal, double? vertical}) => EdgeInsets.symmetric(
  horizontal: horizontal ?? horizontalScreenPaddingValue,
  vertical: vertical ?? verticalScreenPaddingValue,
);
