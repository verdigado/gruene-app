import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/utils/error_message.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class TokenInputScreen extends StatefulWidget {
  const TokenInputScreen({super.key});

  @override
  State<TokenInputScreen> createState() => _TokenInputScreenState();
}

class _TokenInputScreenState extends State<TokenInputScreen> {
  final TextEditingController urlInput = TextEditingController();

  void onSubmit(BuildContext context) async {
    String value = urlInput.text;
    var bloc = context.read<MfaBloc>();
    if (bloc.state.isLoading) {
      return;
    }
    bloc.add(SetupMfa(value));

    if (!context.mounted) return;

    final error = bloc.state.error;
    if (error != null) {
      showSnackBar(context, getErrorMessage(error));
    }

    Future<void> waitForReadyStatus() async {
      while (bloc.state.status != MfaStatus.ready) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      if (context.mounted) {
        context.push(Routes.mfa.path);
      }
    }

    waitForReadyStatus();
  }

  @override
  void dispose() {
    urlInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 119, 24, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.mfa.tokenInput.intro,
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 24),
          Text(
            t.mfa.tokenInput.token,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 6),
          TextField(
            controller: urlInput,
          ),
          SizedBox(height: 55),
          FilledButton(
            onPressed: () => {
              onSubmit(context),
            },
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all<Size>(Size.fromHeight(56)),
            ),
            child: Text(
              t.mfa.tokenInput.submit,
              style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
            ),
          ),
        ],
      ),
    );
  }
}
