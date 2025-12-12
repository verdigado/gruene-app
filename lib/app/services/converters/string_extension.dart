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

  InlineSpan asRichText(BuildContext context) {
    var spans = <TextSpan>[];

    var regex = RegExp(
      r'(?:http[s]?:\/\/.)?(?:www\.)?[-a-zA-Z0-9@%._\+~#=]{2,256}\.[a-z]{2,6}\b(?:[-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)',
    );

    var currentText = this;
    var match = regex.firstMatch(currentText);
    while (match != null) {
      spans.add(TextSpan(text: currentText.substring(0, match.start)));
      var link = currentText.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: link,
          style: TextStyle(color: ThemeColors.textCancel, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => openUrl(link, context),
        ),
      );
      currentText = currentText.substring(match.end);
      match = regex.firstMatch(currentText);
    }
    spans.add(TextSpan(text: currentText));
    return TextSpan(children: spans);
  }

  bool isNullOrEmpty() => isEmpty;
}

extension NullableStringExtension on String? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
  String safe() => this ?? '';
}
