import 'package:flutter/material.dart';

const double horizontalScreenPaddingValue = 16;
const EdgeInsets horizontalScreenPadding = EdgeInsets.symmetric(horizontal: horizontalScreenPaddingValue);

const double topScreenPaddingValue = 24;
const double bottomScreenPaddingValue = 48;
const EdgeInsets verticalScreenPadding = EdgeInsets.only(top: topScreenPaddingValue, bottom: bottomScreenPaddingValue);

const EdgeInsets screenPadding = EdgeInsets.only(
  left: horizontalScreenPaddingValue,
  right: horizontalScreenPaddingValue,
  top: topScreenPaddingValue,
  bottom: bottomScreenPaddingValue
);

EdgeInsets screenPaddingSymmetric({double? horizontal, double? vertical}) => EdgeInsets.only(
  left: horizontal ?? horizontalScreenPaddingValue,
  right: horizontal ?? horizontalScreenPaddingValue,
  top: vertical ?? topScreenPaddingValue,
  bottom: vertical ?? bottomScreenPaddingValue
);
