import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/utils/error_message.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';
import 'package:gruene_app/i18n/translations.g.dart';

Future<void> waitForReadyStatus(BuildContext context, MfaBloc bloc) async {
  while (bloc.state.status != MfaStatus.ready) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  if (context.mounted) {
    while (context.canPop()) {
      context.pop();
    }
    final bloc = context.read<AuthBloc>();
    if (bloc.state is Unauthenticated) {
      context.push(Routes.mfaLogin.path);
    }
  }
}

void setupMfa(BuildContext context, String actionTokenUrl) {
  // Prevent authenticator registration with arbitrary keycloak instances
  if (!actionTokenUrl.startsWith(Config.oidcIssuer)) {
    showSnackBar(context, t.mfa.tokenScan.oidcIssuerMissmatch);
    return;
  }

  final bloc = context.read<MfaBloc>();
  if (bloc.state.isLoading) {
    return;
  }

  bloc.add(SetupMfa(actionTokenUrl));

  if (!context.mounted) return;

  final error = bloc.state.error;
  if (error != null) {
    showSnackBar(context, getErrorMessage(error));
    return;
  }

  waitForReadyStatus(context, bloc);
}
