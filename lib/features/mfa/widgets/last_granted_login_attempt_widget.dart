import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:intl/intl.dart';

class LastGrantedLoginAttemptWidget extends StatelessWidget {
  const LastGrantedLoginAttemptWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<MfaBloc, MfaState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                offset: Offset(2, 4),
                blurRadius: 16,
                spreadRadius: 7,
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.mfa.ready.lastLoginAttempt,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.mfa.ready.loginAttemptApproved,
                    style: theme.textTheme.bodyMedium?.apply(fontWeightDelta: 3),
                  ),
                  Text(
                    state.lastGrantedLoginAttempt!.clientName,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${state.lastGrantedLoginAttempt!.browser}, ${state.lastGrantedLoginAttempt!.os} (${state.lastGrantedLoginAttempt!.ipAddress})',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${DateFormat('dd.MM.yyyy, HH:mm:ss').format(state.lastGrantedLoginAttempt!.loggedInAt)} ${t.mfa.ready.oclock}',
                    style: theme.textTheme.bodyMedium?.apply(color: ThemeColors.textDisabled),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
