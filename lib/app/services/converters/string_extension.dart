part of '../converters.dart';

extension StringExtension on String {
  String appendIfNotEmpty(String text) {
    if (text.trim().isEmpty) return this;
    return this + text;
  }

  String appendLineIfNotEmpty(String text) {
    if (text.trim().isEmpty) return this;
    return '$this\n$text';
  }

  bool isNetworkImageUrl() => Uri.parse(this).hasScheme;
}
