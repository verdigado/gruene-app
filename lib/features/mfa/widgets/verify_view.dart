import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

class VerifyView extends StatefulWidget {
  const VerifyView({super.key});

  @override
  State<VerifyView> createState() => _VerifyViewState();
}

class _VerifyViewState extends State<VerifyView> {
  final LocalAuthentication _auth = LocalAuthentication();

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
    if (granted) {
      try {
        bool authenticated = await _auth.authenticate(
          localizedReason: t.mfa.verify.authenticateForApproval,
          options: const AuthenticationOptions(useErrorDialogs: true, stickyAuth: true),
        );
        if (!mounted) return;
        context.read<MfaBloc>().add(SendReply(authenticated));
      } catch (e) {
        if (!mounted) return;
        context.read<MfaBloc>().add(SendReply(false));
      }
    } else {
      if (!mounted) return;
      context.read<MfaBloc>().add(SendReply(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MfaBloc, MfaState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: SizedBox(height: 108, child: SvgPicture.asset('assets/graphics/mfa_verify.svg'))),
            const SizedBox(height: 16),
            Text(t.mfa.verify.title, textAlign: TextAlign.center, style: theme.textTheme.displayLarge),
            const SizedBox(height: 16),
            Text(t.mfa.verify.intro, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text(
              state.loginAttempt!.clientName,
              style: theme.textTheme.bodyMedium?.apply(fontWeightDelta: 3),
              textAlign: TextAlign.center,
            ),
            Text(
              '${state.loginAttempt!.browser}, ${state.loginAttempt!.os} (${state.loginAttempt!.ipAddress})',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              '${DateFormat('dd.MM.yyyy, HH:mm:ss').format(state.loginAttempt!.loggedInAt)} ${t.mfa.verify.oclock}',
              style: theme.textTheme.bodyMedium?.apply(color: ThemeColors.textDisabled),
              textAlign: TextAlign.center,
            ),
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
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: () => onReply(false),
              style: ButtonStyle(minimumSize: WidgetStateProperty.all<Size>(Size.fromHeight(56))),
              child: Text(
                t.mfa.verify.deny,
                style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.tertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
