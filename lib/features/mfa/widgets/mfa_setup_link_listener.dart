import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';

/// Sets up the app as authenticator when the MFA setup link (`de.gruene.wkapp.mfa://setup?url=<activation token url>`)
/// is tapped on the Keycloak setup page during an app login, as the QR code cannot be scanned on the same device.
///
/// The link is intercepted natively without changing the app UI, see `MfaSetupLink.kt` and `AppDelegate.swift`.
/// The login browser stays open and continues the login on its own once the registration succeeded.
class MfaSetupLinkListener extends StatefulWidget {
  final Widget child;

  const MfaSetupLinkListener({super.key, required this.child});

  @override
  State<MfaSetupLinkListener> createState() => _MfaSetupLinkListenerState();
}

class _MfaSetupLinkListenerState extends State<MfaSetupLinkListener> {
  static final _channel = MethodChannel('${Config.appId}/mfa_setup_link');

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLink') _onLink(call.arguments as String);
    });
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  void _onLink(String link) {
    final activationTokenUrl = Uri.tryParse(link)?.queryParameters['url'];
    // Register silently only from the login browser of the app and never with arbitrary keycloak instances
    final isValid =
        activationTokenUrl != null &&
        activationTokenUrl.startsWith(Config.oidcIssuer) &&
        context.read<AuthBloc>().state is LoginInProgress;
    if (!isValid) {
      logger.w('Ignoring MFA setup link');
      return;
    }
    context.read<MfaBloc>().add(SetupMfa(activationTokenUrl));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
