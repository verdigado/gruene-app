import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/app/widgets/alert.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/features/guests/models/keycloak_password_policy.dart';
import 'package:gruene_app/features/guests/utils/birth_date.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_details_step.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_login_step.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_password_step.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_welcome_step.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/step_progress.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

enum _OnboardingStep { welcome, details, password, login }

class GuestOnboardingScreen extends StatefulWidget {
  final GuestOnboardingExtra extra;

  const GuestOnboardingScreen({super.key, required this.extra});

  @override
  State<GuestOnboardingScreen> createState() => _GuestOnboardingScreenState();
}

class _GuestOnboardingScreenState extends State<GuestOnboardingScreen> {
  _OnboardingStep _step = _OnboardingStep.welcome;

  @override
  Widget build(BuildContext context) {
    final previousStep = switch (_step) {
      _OnboardingStep.welcome || _OnboardingStep.login => null,
      _ => _OnboardingStep.values[_step.index - 1],
    };
    final hasPreviousStep = previousStep != null;

    return PopScope(
      canPop: !hasPreviousStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && hasPreviousStep) {
          setState(() => _step = previousStep);
        }
      },
      child: Scaffold(
        appBar: MainAppBar(title: t.guests.onboarding.title, leadingAction: const BackButton()),
        body: SafeArea(
          child: _OnboardingSteps(
            token: widget.extra.token,
            invitation: widget.extra.invitation,
            step: _step,
            setStep: (step) => setState(() => _step = step),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSteps extends StatefulWidget {
  final String token;
  final GuestInvitationLookup invitation;
  final _OnboardingStep step;
  final void Function(_OnboardingStep step) setStep;

  const _OnboardingSteps({required this.token, required this.invitation, required this.step, required this.setStep});

  @override
  State<_OnboardingSteps> createState() => _OnboardingStepsState();
}

class _OnboardingStepsState extends State<_OnboardingSteps> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _birthDate = TextEditingController();
  final _privacyConsent = ValueNotifier(false);
  final _password = TextEditingController();
  final _passwordRepeat = TextEditingController();
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
    _privacyConsent.dispose();
    _password.dispose();
    _passwordRepeat.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _acceptInvitation() => tryAndNotify(
    function: () => GetIt.I<GuestApiService>().acceptInvitation(
      token: widget.token,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      birthDate: parseBirthDate(_birthDate.text)!,
      password: _password.text,
    ),
    onSuccess: (_, _) {
      if (!mounted) return;
      _password.clear();
      _passwordRepeat.clear();
      widget.setStep(_OnboardingStep.login);
    },
    onError: _onAcceptInvitationError,
    context: context,
  );

  void _onAcceptInvitationError(BuildContext context, Object error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case HttpStatus.badRequest when error.body?['errorCode'] == 'invalidPassword':
          if (mounted) setState(() => _rejectedPassword = _password.text);
          return;
        case HttpStatus.notFound:
          _leaveOnboarding(context, title: t.guests.onboarding.invalid.title, hint: t.guests.onboarding.invalid.hint);
          return;
        case HttpStatus.conflict || HttpStatus.unprocessableEntity:
          _leaveOnboarding(context, title: t.guests.onboarding.refused.title, hint: t.guests.onboarding.refused.hint);
          return;
      }
    }

    final byStatusCode = {HttpStatus.badRequest: t.guests.onboarding.details.invalid};
    final errorMessage = getErrorMessage(error, byStatusCode: byStatusCode);
    showSnackBar(context: context, text: errorMessage);
  }

  Widget _buildFormStep({required Widget content, required String action, required void Function()? onAction}) => Form(
    key: _formKey,
    child: ExpandingScrollView(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      padding: screenPadding,
      spacing: 24,
      children: [
        if (widget.step.index > 0) StepProgress(current: widget.step.index, total: _OnboardingStep.login.index + 1),
        content,
        FilledButton(onPressed: onAction, child: Text(action)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final email = widget.invitation.email;
    final passwordPolicy = KeycloakPasswordPolicy(password: _password.text, repeat: _passwordRepeat.text, email: email);

    return switch (widget.step) {
      _OnboardingStep.welcome => _buildFormStep(
        content: OnboardingWelcomeStep(invitation: widget.invitation),
        action: t.guests.onboarding.welcome.action,
        onAction: () => widget.setStep(_OnboardingStep.details),
      ),
      _OnboardingStep.details => _buildFormStep(
        content: OnboardingDetailsStep(
          firstName: _firstName,
          lastName: _lastName,
          birthDate: _birthDate,
          privacyConsent: _privacyConsent,
        ),
        action: t.common.actions.next,
        onAction: () => _formKey.currentState!.validate() ? widget.setStep(_OnboardingStep.password) : null,
      ),
      _OnboardingStep.password => _buildFormStep(
        content: OnboardingPasswordStep(
          policy: passwordPolicy,
          password: _password,
          passwordRepeat: _passwordRepeat,
          rejected: _password.text == _rejectedPassword,
        ),
        action: t.guests.onboarding.password.action,
        onAction: passwordPolicy.fulfilled ? _acceptInvitation : null,
      ),
      _OnboardingStep.login => _buildFormStep(
        content: OnboardingLoginStep(email: email),
        action: t.common.actions.login,
        onAction: () {
          context.pop();
          context.read<AuthBloc>().add(LoginRequested(loginHint: email));
        },
      ),
    };
  }
}

Future<void> _leaveOnboarding(BuildContext context, {required String title, required String hint}) async {
  await showAlertDialog(context, title: title, content: hint);
  if (context.mounted) context.pop();
}

class GuestOnboardingExtra {
  final String token;
  final GuestInvitationLookup invitation;

  const GuestOnboardingExtra({required this.token, required this.invitation});
}
