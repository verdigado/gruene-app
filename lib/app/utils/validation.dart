import 'package:gruene_app/i18n/translations.g.dart';

// Only catches obvious typos
final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return t.common.validation.emailRequired;
  if (!emailPattern.hasMatch(email)) return t.common.validation.emailInvalid;
  return null;
}
