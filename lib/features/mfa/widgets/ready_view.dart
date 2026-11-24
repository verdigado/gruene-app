import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/widgets/alert.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';
import 'package:gruene_app/features/mfa/widgets/login_attempt_card.dart';
import 'package:gruene_app/features/mfa/widgets/no_login_attempt_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class ReadyView extends StatefulWidget {
  const ReadyView({super.key});

  @override
  State<ReadyView> createState() => _ReadyViewState();
}

class _ReadyViewState extends State<ReadyView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MfaBloc>().add(RefreshMfa());
      _startPeriodicRefresh();
    });
  }

  void _startPeriodicRefresh() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      context.read<MfaBloc>().add(RefreshMfa(raiseError: false));
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

    return BlocBuilder<MfaBloc, MfaState>(
      builder: (context, state) {
        final lastGrantedChallenge = state.lastGrantedChallenge;
        return ExpandingScrollView(
          spacing: 16,
          children: [
            Center(child: SizedBox(height: 160, child: SvgPicture.asset('assets/graphics/mfa_ready.svg'))),
            NoLoginAttemptCard(lastRefresh: state.lastRefresh),
            Center(
              child: FilledButton(
                onPressed: () => context.read<MfaBloc>().add(RefreshMfa()),
                child: Text(
                  t.mfa.ready.refresh,
                  style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
                ),
              ),
            ),
            if (lastGrantedChallenge != null)
              LoginAttemptCard(challenge: lastGrantedChallenge, title: t.mfa.ready.lastApprovedLogin),
            Spacer(),
            OutlinedButton(onPressed: _deleteMfa, child: Text(t.mfa.ready.delete.title)),
          ],
        );
      },
    );
  }

  void _deleteMfa() => showConfirmationDialog(
    context,
    title: t.mfa.ready.delete.title,
    label: t.common.actions.delete,
    onConfirmed: () => context.read<MfaBloc>().add(DeleteMfa()),
    content: Text.rich(
      t.mfa.ready.delete.description(
        appName: TextSpan(text: t.common.appName),
        openAccountSettings: (text) => TextSpan(
          text: text,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: ThemeColors.primary, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => openUrl(mfaSettingsUrl, context),
        ),
      ),
    ),
  );
}
