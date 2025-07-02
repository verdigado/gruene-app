import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_app/app/theme/theme.dart';
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
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ExpandingScrollView(
          children: [
            const SizedBox(height: 60),
            Center(child: SizedBox(height: 155, child: SvgPicture.asset('assets/graphics/mfa_ready.svg'))),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => {context.read<MfaBloc>().add(RefreshMfa())},
              child: Text(
                t.mfa.ready.refresh,
                style: theme.textTheme.bodyMedium!.apply(color: ThemeColors.text, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 3),
            state.lastGrantedLoginAttempt != null ? LoginAttemptCard() : NoLoginAttemptCard(),
            const SizedBox(height: 16),
            Text(t.mfa.ready.betaVersion, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            TextButton(
              onPressed: () => showMfaDeletionDialog(context),
              child: Text(
                t.mfa.ready.delete.title,
                style: theme.textTheme.bodyMedium!.apply(color: ThemeColors.text, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void showMfaDeletionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(t.mfa.ready.delete.text),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.common.actions.cancel)
            ),
            TextButton(
              onPressed: () {
                context.read<MfaBloc>().add(DeleteMfa());
                Navigator.of(context).pop();
              },
              child: Text(t.mfa.ready.delete.submit),
            ),
          ],
        );
      },
    );
  }
}
