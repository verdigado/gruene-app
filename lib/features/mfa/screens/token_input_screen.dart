import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/features/mfa/util/setup_mfa.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class TokenInputScreen extends StatefulWidget {
  const TokenInputScreen({super.key});

  @override
  State<TokenInputScreen> createState() => _TokenInputScreenState();
}

class _TokenInputScreenState extends State<TokenInputScreen> {
  final TextEditingController urlInput = TextEditingController();

  void onSubmit(BuildContext context) async {
    String actionTokenUrl = urlInput.text;
    setupMfa(context, actionTokenUrl);
  }

  @override
  void dispose() {
    urlInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MainAppBar(title: t.mfa.tokenInput.title),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ExpandingScrollView(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(t.mfa.tokenInput.intro, style: theme.textTheme.titleMedium),
            const SizedBox(height: 32),
            Text(t.mfa.tokenInput.token, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            TextField(controller: urlInput),
            const SizedBox(height: 48),
            FilledButton(
              onPressed: () => {onSubmit(context)},
              style: ButtonStyle(minimumSize: WidgetStateProperty.all<Size>(Size.fromHeight(56))),
              child: Text(
                t.mfa.tokenInput.submit,
                style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
