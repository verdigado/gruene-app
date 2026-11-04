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
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_details_step.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_message.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_password_step.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestOnboardingScreen extends StatelessWidget {
  final String? token;

  const GuestOnboardingScreen({super.key, required this.token});

  Future<({GuestInvitationLookup? invitation})> _lookUp(String token) async {
    try {
      return (invitation: await GetIt.I<GuestApiService>().lookupInvitation(token));
    } on ApiException catch (error) {
      if (error.statusCode == HttpStatus.notFound) return (invitation: null);
      rethrow;
    }
  }

  void _goToLogin(BuildContext context) {
    markInvitationHandled(token);
    context.go(Routes.login.path);
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

    final invalidInvitation = OnboardingMessage(
      title: t.guests.onboarding.invalid.title,
      hint: t.guests.onboarding.invalid.hint,
      action: t.guests.onboarding.invalid.action,
      onAction: () => _goToLogin(context),
    );

    final token = this.token;
    if (token == null) return invalidInvitation;

    return FutureLoadingScreen(
      key: ValueKey(token),
      load: () => _lookUp(token),
      loadingLayoutBuilder: (child) => CleanLayout(showAppBar: false, child: child),
      buildChild: (result, _) {
        final invitation = result.invitation;
        return invitation == null ? invalidInvitation : _OnboardingSteps(token: token, invitation: invitation);
      },
    );
  }
}

enum _OnboardingStep { welcome, details, password, done, refused }

enum _AcceptResult { accepted, passwordRejected, refused }

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

  String _getAcceptErrorMessage(Object error) => getErrorMessage(
    error,
    byStatusCode: {
      HttpStatus.badRequest: t.guests.onboarding.details.invalid,
      HttpStatus.notFound: t.guests.onboarding.invalid.title,
    },
  );

  /// Both refusals look the same to the guest, because the reason could reveal a party membership. Only a `409` ends
  /// the invitation. After a `422` the link has to keep working for when the records are clarified.
  _AcceptResult _handleRefusal(ApiException error) {
    if (error.statusCode == HttpStatus.conflict) markInvitationHandled(widget.token);
    return _AcceptResult.refused;
  }

  Future<void> _accept() async {
    final password = _password.text;

    await tryAndNotify(
      function: () async {
        try {
          await GetIt.I<GuestApiService>().acceptInvitation(
            token: widget.token,
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            birthDate: parseBirthDate(_birthDate.text)!,
            password: password,
          );
          return _AcceptResult.accepted;
        } on ApiException catch (error) {
          if (error.isInvalidPassword) return _AcceptResult.passwordRejected;
          if (error.statusCode == HttpStatus.conflict || error.statusCode == HttpStatus.unprocessableEntity) {
            return _handleRefusal(error);
          }
          rethrow;
        }
      },
      onSuccess: (_, result) {
        if (result == _AcceptResult.accepted) markInvitationHandled(widget.token);
        if (!mounted) return;
        if (result == _AcceptResult.passwordRejected) return setState(() => _rejectedPassword = password);
        _password.clear();
        _passwordRepeat.clear();
        setState(() {
          _step = result == _AcceptResult.accepted ? _OnboardingStep.done : _OnboardingStep.refused;
        });
      },
      getErrorMessage: _getAcceptErrorMessage,
      context: context,
    );
  }

  void _goBack() => setState(() {
    if (_step == _OnboardingStep.details) _step = _OnboardingStep.welcome;
    if (_step == _OnboardingStep.password) _step = _OnboardingStep.details;
  });

  bool get _rulesFulfilled =>
      PasswordRules(password: _password.text, repeat: _passwordRepeat.text, email: widget.invitation.email).fulfilled;

  @override
  Widget build(BuildContext context) {
    if (_step == _OnboardingStep.done) {
      return OnboardingMessage(
        title: t.guests.onboarding.done.title,
        hint: t.guests.onboarding.done.hint,
        action: t.login.loginMembers,
        onAction: () => context.read<AuthBloc>().add(LoginRequested(loginHint: widget.invitation.email)),
      );
    }

    if (_step == _OnboardingStep.refused) {
      return OnboardingMessage(
        title: t.guests.onboarding.refused.title,
        hint: t.guests.onboarding.refused.hint,
        action: t.guests.onboarding.invalid.action,
        onAction: () => context.go(Routes.login.path),
      );
    }

    final canGoBack = _step != _OnboardingStep.welcome;

    return PopScope(
      canPop: !canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: CleanLayout(
        showAppBar: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: screenPadding,
            children: [
              if (canGoBack) ...[_Progress(current: _step.index, total: 2), const SizedBox(height: 24)],
              switch (_step) {
                _OnboardingStep.details => OnboardingDetailsStep(
                  firstName: _firstName,
                  lastName: _lastName,
                  birthDate: _birthDate,
                ),
                _OnboardingStep.password => OnboardingPasswordStep(
                  email: widget.invitation.email,
                  password: _password,
                  passwordRepeat: _passwordRepeat,
                  rejected: _password.text == _rejectedPassword,
                ),
                _ => _WelcomeStep(invitation: widget.invitation),
              },
              const SizedBox(height: 24),
              switch (_step) {
                _OnboardingStep.details => FilledButton(onPressed: _submitDetails, child: Text(t.common.actions.next)),
                _OnboardingStep.password => FilledButton(
                  onPressed: _rulesFulfilled ? _accept : null,
                  child: Text(t.guests.onboarding.password.action),
                ),
                _ => FilledButton(
                  onPressed: () => setState(() => _step = _OnboardingStep.details),
                  child: Text(t.guests.onboarding.welcome.action),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final GuestInvitationLookup invitation;

  const _WelcomeStep({required this.invitation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inviter = invitation.inviterName;
    final division = invitation.divisionName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        const SizedBox(height: 32),
        Icon(Icons.waving_hand_outlined, size: 56, color: theme.primaryColor),
        Text(t.guests.onboarding.welcome.title, style: theme.textTheme.titleLarge),
        Text(
          inviter != null && division != null
              ? t.guests.onboarding.welcome.invitedBy(inviter: inviter, division: division)
              : t.guests.onboarding.welcome.invited,
          style: theme.textTheme.bodyMedium,
        ),
        Text(t.guests.onboarding.welcome.hint, style: theme.textTheme.bodyMedium),
      ],
    );
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
