// Only catches obvious typos
import 'package:gruene_app/i18n/translations.g.dart';

final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return t.guests.validation.emailRequired;
  if (!emailPattern.hasMatch(email)) return t.guests.validation.emailInvalid;
  return null;
}
