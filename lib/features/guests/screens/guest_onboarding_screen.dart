import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/widgets/clean_layout.dart';
import 'package:gruene_app/features/guests/utils/guest_onboarding.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_details_step.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_message.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_password_step.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_welcome_step.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestOnboardingScreen extends StatelessWidget {
  final String? token;

  const GuestOnboardingScreen({super.key, required this.token});

  /// A record, because `FutureLoadingScreen` treats null data as an error.
  Future<({GuestInvitationLookup? invitation})> _lookUp(String token) async {
    try {
      return (invitation: await GetIt.I<GuestApiService>().lookupInvitation(token));
    } on ApiException catch (error) {
      if (error.statusCode == HttpStatus.notFound) return (invitation: null);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<AuthBloc>().state is Authenticated) {
      return OnboardingMessage(
        title: t.guests.onboarding.loggedIn.title,
        hint: t.guests.onboarding.loggedIn.hint,
        action: t.guests.onboarding.loggedIn.action,
        onAction: () => context.go(Routes.news.path),
      );
    }

    final token = this.token;
    if (token == null) return const _InvalidInvitationMessage();

    return FutureLoadingScreen(
      key: ValueKey(token),
      load: () => _lookUp(token),
      loadingLayoutBuilder: (child) => CleanLayout(showAppBar: false, child: child),
      buildChild: (result, _) {
        final invitation = result.invitation;
        return invitation == null
            ? _InvalidInvitationMessage(token: token)
            : _OnboardingSteps(token: token, invitation: invitation);
      },
    );
  }
}

class _InvalidInvitationMessage extends StatelessWidget {
  final String? token;

  const _InvalidInvitationMessage({this.token});

  @override
  Widget build(BuildContext context) {
    return OnboardingMessage(
      title: t.guests.onboarding.invalid.title,
      hint: t.guests.onboarding.invalid.hint,
      action: t.guests.onboarding.invalid.action,
      onAction: () {
        markInvitationHandled(token);
        context.go(Routes.login.path);
      },
    );
  }
}

/// The progress display numbers the form steps by their index.
enum _OnboardingStep { welcome, details, password, done, refused, invalid }

class _OnboardingSteps extends StatefulWidget {
  final String token;
  final GuestInvitationLookup invitation;

  const _OnboardingSteps({required this.token, required this.invitation});

  @override
  State<_OnboardingSteps> createState() => _OnboardingStepsState();
}

class _OnboardingStepsState extends State<_OnboardingSteps> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _birthDate = TextEditingController();
  final _password = TextEditingController();
  final _passwordRepeat = TextEditingController();
  _OnboardingStep _step = _OnboardingStep.welcome;
  String? _rejectedPassword;

  @override
  void initState() {
    super.initState();
    _password.addListener(_rebuild);
    _passwordRepeat.addListener(_rebuild);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _birthDate.dispose();
    _password.dispose();
    _passwordRepeat.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _submitDetails() {
    if (_formKey.currentState!.validate()) {
      setState(() => _step = _OnboardingStep.password);
    }
  }

  /// Returns the step to continue with, which stays the password step if the password got rejected.
  Future<_OnboardingStep> _submitAcceptance(String password) async {
    try {
      await GetIt.I<GuestApiService>().acceptInvitation(
        token: widget.token,
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        birthDate: parseBirthDate(_birthDate.text)!,
        password: password,
      );
      markInvitationHandled(widget.token);
      return _OnboardingStep.done;
    } on ApiException catch (error) {
      switch (error.statusCode) {
        case HttpStatus.badRequest when error.body?['errorCode'] == 'invalidPassword':
          return _OnboardingStep.password;
        // The invitation ended while the form was open, or an earlier try succeeded but its response got lost.
        case HttpStatus.notFound:
          return _OnboardingStep.invalid;
        // Both refusals look the same to the guest, because the reason could reveal a party membership. Only a `409`
        // ends the invitation. After a `422` the link has to keep working for when the records are clarified.
        case HttpStatus.conflict:
          markInvitationHandled(widget.token);
          return _OnboardingStep.refused;
        case HttpStatus.unprocessableEntity:
          return _OnboardingStep.refused;
        default:
          rethrow;
      }
    }
  }

  Future<void> _accept() async {
    final password = _password.text;

    await tryAndNotify(
      function: () => _submitAcceptance(password),
      onSuccess: (_, step) {
        if (!mounted) return;
        if (step == _OnboardingStep.password) return setState(() => _rejectedPassword = password);
        _password.clear();
        _passwordRepeat.clear();
        setState(() => _step = step);
      },
      getErrorMessage: (error) =>
          getErrorMessage(error, byStatusCode: {HttpStatus.badRequest: t.guests.onboarding.details.invalid}),
      context: context,
    );
  }

  Widget _buildFormStep({
    _OnboardingStep? previous,
    required Widget content,
    required String action,
    required void Function()? onAction,
  }) {
    return PopScope(
      canPop: previous == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && previous != null) setState(() => _step = previous);
      },
      child: CleanLayout(
        showAppBar: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: screenPadding,
            children: [
              if (previous != null) ...[
                _Progress(current: _step.index, total: _OnboardingStep.password.index),
                const SizedBox(height: 24),
              ],
              content,
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(action)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.invitation.email;
    final rules = PasswordRules(password: _password.text, repeat: _passwordRepeat.text, email: email);

    return switch (_step) {
      _OnboardingStep.welcome => _buildFormStep(
        content: OnboardingWelcomeStep(invitation: widget.invitation),
        action: t.guests.onboarding.welcome.action,
        onAction: () => setState(() => _step = _OnboardingStep.details),
      ),
      _OnboardingStep.details => _buildFormStep(
        previous: _OnboardingStep.welcome,
        content: OnboardingDetailsStep(firstName: _firstName, lastName: _lastName, birthDate: _birthDate),
        action: t.common.actions.next,
        onAction: _submitDetails,
      ),
      _OnboardingStep.password => _buildFormStep(
        previous: _OnboardingStep.details,
        content: OnboardingPasswordStep(
          rules: rules,
          password: _password,
          passwordRepeat: _passwordRepeat,
          rejected: _password.text == _rejectedPassword,
        ),
        action: t.guests.onboarding.password.action,
        onAction: rules.fulfilled ? _accept : null,
      ),
      _OnboardingStep.done => OnboardingMessage(
        title: t.guests.onboarding.done.title,
        hint: t.guests.onboarding.done.hint,
        action: t.guests.onboarding.done.action,
        onAction: () => context.read<AuthBloc>().add(LoginRequested(loginHint: email)),
      ),
      _OnboardingStep.refused => OnboardingMessage(
        title: t.guests.onboarding.refused.title,
        hint: t.guests.onboarding.refused.hint,
        action: t.guests.onboarding.refused.action,
        onAction: () => context.go(Routes.login.path),
      ),
      _OnboardingStep.invalid => _InvalidInvitationMessage(token: widget.token),
    };
  }
}

class _Progress extends StatelessWidget {
  final int current;
  final int total;

  const _Progress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          t.guests.onboarding.step(current: current, total: total),
          style: theme.textTheme.bodySmall,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: current / total, minHeight: 4, backgroundColor: ThemeColors.grey200),
        ),
      ],
    );
  }
}
