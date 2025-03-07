import 'package:gruene_app/i18n/translations.g.dart';

String getErrorMessage(Object error, {String? defaultMessage}) {
  if (error.toString().contains('Failed host lookup')) {
    return t.error.offlineError;
  }
  return defaultMessage ?? t.error.unknownError;
}
