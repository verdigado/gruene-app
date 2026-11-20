import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/app/utils/extensions.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/widgets/alert.dart';
import 'package:gruene_app/features/guests/repositories/guest_repository.dart';
import 'package:gruene_app/features/guests/screens/guest_onboarding_screen.dart';
import 'package:gruene_app/i18n/translations.g.dart';

/// Path of the invitation link sent to guests, e.g. https://app.gruene.de/guest-invitation#token=abc
const _invitationLinkPath = '/guest-invitation';

bool isInvitationLink(Uri uri) => uri.path == _invitationLinkPath;

String? invitationToken(Uri uri) {
  final token = Uri.splitQueryString(uri.fragment)['token'];
  return token.isNullOrEmpty() ? null : token;
}

Future<void> openInvitationLink(GlobalKey<NavigatorState> navigatorKey, String? token) async {
  final context = navigatorKey.currentContext;
  if (context == null || isInvitationHandled(token)) return;

  if (token == null) {
    showAlertDialog(context, title: t.guests.onboarding.invalid.title, content: t.guests.onboarding.invalid.hint);
    return;
  }

  if (context.read<AuthBloc>().state is Authenticated) {
    showAlertDialog(context, title: t.guests.onboarding.loggedIn.title, content: t.guests.onboarding.loggedIn.hint);
    return;
  }

  await tryAndNotify(
    function: () => GetIt.I<GuestApiService>().lookupInvitation(token),
    context: context,
    onSuccess: (context, invitation) {
      if (invitation == null) {
        markInvitationHandled(token);
        showAlertDialog(context, title: t.guests.onboarding.invalid.title, content: t.guests.onboarding.invalid.hint);
        return;
      }
      context.push(
        Routes.guestOnboarding.path,
        extra: GuestOnboardingExtra(token: token, invitation: invitation),
      );
    },
    onError: (context, error) => showAlertDialog(
      context,
      title: t.guests.onboarding.lookupFailed.title,
      content: getErrorMessage(error),
      action: TextButton(
        onPressed: () {
          Navigator.pop(context);
          openInvitationLink(navigatorKey, token);
        },
        child: Text(t.error.retry),
      ),
    ),
  );
}
