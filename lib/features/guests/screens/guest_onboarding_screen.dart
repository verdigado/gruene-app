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
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/app/widgets/step_progress.dart';
import 'package:gruene_app/features/guests/utils/guest_onboarding.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_details_step.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_message.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_password_step.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/onboarding_welcome_step.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

enum _OnboardingStep { welcome, details, password, done }

class GuestOnboardingScreen extends StatefulWidget {
  final String? token;

  const GuestOnboardingScreen({super.key, required this.token});

  @override
  State<GuestOnboardingScreen> createState() => _GuestOnboardingScreenState();
}

class _GuestOnboardingScreenState extends State<GuestOnboardingScreen> {
  _OnboardingStep _step = _OnboardingStep.welcome;

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

    final token = widget.token;
    if (token == null) return const _InvalidInvitationMessage();

    final previousStep = _step.index > 0 ? _OnboardingStep.values[_step.index - 1] : null;
    final hasPreviousStep = previousStep != null;

    return PopScope(
      canPop: !hasPreviousStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && hasPreviousStep) {
          setState(() => _step = previousStep);
        }
      },
      child: Scaffold(
        appBar: MainAppBar(
          title: t.guests.onboarding.title,
          leadingAction: hasPreviousStep ? const BackButton() : null,
        ),
        body: SafeArea(
          child: FutureLoadingScreen(
            key: ValueKey(token),
            load: () => GetIt.I<GuestApiService>().lookupInvitation(token),
            buildChild: (invitation, _) => invitation == null
                ? _InvalidInvitationMessage(token: token)
                : _OnboardingSteps(
                    token: token,
                    invitation: invitation,
                    step: _step,
                    setStep: (step) => setState(() => _step = step),
                  ),
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

  /// Returns the step to continue with, which stays the password step if the password got rejected.
  Future<_OnboardingStep> _submitAcceptance() async {
    try {
      await GetIt.I<GuestApiService>().acceptInvitation(
        token: widget.token,
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        birthDate: parseBirthDate(_birthDate.text)!,
        password: _password.text,
      );
      markInvitationHandled(widget.token);
      return _OnboardingStep.done;
    } on ApiException catch (error) {
      switch (error.statusCode) {
        case HttpStatus.badRequest when error.body?['errorCode'] == 'invalidPassword':
          return _OnboardingStep.password;
        // case HttpStatus.notFound:
        //   return _OnboardingStep.invalid;
        // case HttpStatus.conflict:
        //   markInvitationHandled(widget.token);
        //   return _OnboardingStep.refused;
        // case HttpStatus.unprocessableEntity:
        //   return _OnboardingStep.refused;
        default:
          rethrow;
      }
    }
  }

  Future<_OnboardingStep?> _acceptInvitation() => tryAndNotify(
    function: () => _submitAcceptance(),
    onSuccess: (_, step) {
      if (!mounted) return;
      if (step == _OnboardingStep.password) return setState(() => _rejectedPassword = _password.text);
      _password.clear();
      _passwordRepeat.clear();
      widget.setStep(step);
    },
    getErrorMessage: (error) =>
        getErrorMessage(error, byStatusCode: {HttpStatus.badRequest: t.guests.onboarding.details.invalid}),
    context: context,
  );

  Widget _buildFormStep({
    _OnboardingStep? previous,
    required Widget content,
    required String action,
    required void Function()? onAction,
  }) => Form(
    key: _formKey,
    child: ExpandingScrollView(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      padding: screenPadding,
      spacing: 24,
      children: [
        if (previous != null) StepProgress(current: widget.step.index, total: _OnboardingStep.done.index + 1),
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
      _OnboardingStep.done => OnboardingMessage(
        title: t.guests.onboarding.done.title,
        hint: t.guests.onboarding.done.hint,
        action: t.guests.onboarding.done.action,
        onAction: () => context.read<AuthBloc>().add(LoginRequested(loginHint: email)),
      ),
      // _OnboardingStep.refused =>
      //     OnboardingMessage(
      //       title: t.guests.onboarding.refused.title,
      //       hint: t.guests.onboarding.refused.hint,
      //       action: t.guests.onboarding.refused.action,
      //       onAction: () => context.go(Routes.login.path),
      //     ),
      // _OnboardingStep.invalid => _InvalidInvitationMessage(token: widget.token),
    };
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
