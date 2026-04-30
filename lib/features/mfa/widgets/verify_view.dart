import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';
import 'package:gruene_app/features/mfa/widgets/login_attempt_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:local_auth/local_auth.dart';

class VerifyView extends StatefulWidget {
  const VerifyView({super.key});

  @override
  State<VerifyView> createState() => _VerifyViewState();
}

class _VerifyViewState extends State<VerifyView> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    final state = context.read<MfaBloc>().state;
    startTimer(state);
  }

  void startTimer(MfaState state) {
    Timer(Duration(seconds: state.loginAttempt!.expiresIn), () {
      context.read<MfaBloc>().add(IdleTimeout());
    });
  }

  Future<void> onReply(bool granted) async {
    if (!granted) {
      context.read<MfaBloc>().add(SendReply(false));
      return;
    }
    try {
      bool authenticated = await _authenticateUser();
      if (authenticated && mounted) {
        context.read<MfaBloc>().add(SendReply(true));
        return;
      }
    } on LocalAuthException {
      // Just show an error in the snackbar
    }
    if (mounted) {
      showSnackBar(context, t.mfa.verify.authenticationFailed);
    }
  }

  Future<bool> _authenticateUser() async {
    if (!await _localAuthentication.isDeviceSupported()) {
      return true;
    }

    return await _localAuthentication.authenticate(
      localizedReason: t.mfa.verify.authenticateForApproval,
      persistAcrossBackgrounding: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MfaBloc, MfaState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ExpandingScrollView(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Center(child: SizedBox(height: 108, child: SvgPicture.asset('assets/graphics/mfa_verify.svg'))),
            const SizedBox(height: 16),
            Text(t.mfa.verify.title, textAlign: TextAlign.center, style: theme.textTheme.displayLarge),
            const SizedBox(height: 16),
            Text(t.mfa.verify.description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            LoginAttemptCard(loginAttempt: state.loginAttempt!),
            const SizedBox(height: 16),
            Spacer(),
            FilledButton(
              onPressed: () => {onReply(true)},
              style: ButtonStyle(minimumSize: WidgetStateProperty.all<Size>(Size.fromHeight(56))),
              child: Text(
                t.mfa.verify.approve,
                style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => onReply(false),
              style: ButtonStyle(minimumSize: WidgetStateProperty.all<Size>(Size.fromHeight(56))),
              child: Text(
                t.mfa.verify.deny,
                style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.tertiary),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
