import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoLoginAttemptWidget extends StatefulWidget {
  const NoLoginAttemptWidget({super.key});

  @override
  State<NoLoginAttemptWidget> createState() => _NoLoginAttemptWidgetState();
}

class _NoLoginAttemptWidgetState extends State<NoLoginAttemptWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = LocaleSettings.currentLocale.languageCode;
    return BlocBuilder<MfaBloc, MfaState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(2, 4), blurRadius: 16, spreadRadius: 7),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.mfa.ready.noLoginAttempt, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    '${t.mfa.ready.lastRefreshAt}: ${state.lastRefresh != null ? timeago.format(state.lastRefresh!, locale: locale) : 'nie'}',
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
