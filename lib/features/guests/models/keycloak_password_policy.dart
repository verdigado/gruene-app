class KeycloakPasswordPolicy {
  final String password;
  final String repeat;
  final String email;

  static const minLength = 12;
  static const maxLength = 256;

  const KeycloakPasswordPolicy({required this.password, required this.repeat, required this.email});

  bool get longEnough => password.length >= minLength;

  bool get notTooLong => password.length <= maxLength;

  bool get hasLetters =>
      password.contains(RegExp(r'\p{Ll}', unicode: true)) && password.contains(RegExp(r'\p{Lu}', unicode: true));

  bool get hasDigit => password.contains(RegExp(r'\p{Nd}', unicode: true));

  bool get differsFromEmail => password.isNotEmpty && password.toLowerCase() != email.toLowerCase();

  bool get matches => password.isNotEmpty && password == repeat;

  bool get fulfilled => longEnough && notTooLong && hasLetters && hasDigit && differsFromEmail && matches;
}
