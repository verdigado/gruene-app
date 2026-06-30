import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';

OverlayEntry? _overlay;

void showLoadingOverlay(BuildContext context) {
  _overlay = OverlayEntry(
    builder: (_) => Stack(
      children: [
        ModalBarrier(dismissible: false, color: ThemeColors.text.withValues(alpha: 0.5)),
        Center(child: CircularProgressIndicator()),
      ],
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(_overlay!);
}

void hideLoadingOverlay() {
  _overlay?.remove();
  _overlay = null;
}

Future<T?> tryAndNotify<T>({
  required Future<T> Function() function,
  required BuildContext context,
  String? errorMessage,
  void Function(T? value)? onSuccess,
  void Function(bool loading)? setLoading,
}) async {
  final rootContext = Navigator.of(context, rootNavigator: true).context;
  setLoading != null ? setLoading(true) : showLoadingOverlay(context);
  try {
    final value = await function();
    if (onSuccess != null) {
      onSuccess(value);
    }
    return value;
  } catch (error) {
    if (rootContext.mounted) {
      showSnackBar(rootContext, getErrorMessage(error, defaultMessage: errorMessage));
    }
  } finally {
    setLoading != null ? setLoading(false) : hideLoadingOverlay();
  }
  return null;
}
