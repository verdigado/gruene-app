import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/app/utils/validation.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/form_section.dart';
import 'package:gruene_app/app/widgets/hint.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestInviteScreen extends StatefulWidget {
  final List<Division> divisions;

  const GuestInviteScreen({super.key, required this.divisions});

  @override
  State<GuestInviteScreen> createState() => _GuestInviteScreenState();
}

class _GuestInviteScreenState extends State<GuestInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  Division? _division;

  @override
  void initState() {
    super.initState();
    _division = widget.divisions.singleOrNull;
  }

  Future<void> _sendInvitation() async {
    final division = _division;
    if (!_formKey.currentState!.validate() || division == null) return;

    final errorMessageByStatusCode = {400: t.guests.validation.emailInvalid, 409: t.guests.error.openInvitationExists};
    final guestService = GetIt.I<GuestApiService>();

    await tryAndNotify(
      function: () async {
        await Future<void>.delayed(Duration(seconds: 10));
        return guestService.createInvitation(email: _email.trim(), divisionKey: division.divisionKey);
      },
      onSuccess: (context, invitation) {
        showSnackBar(
          context: context,
          text: t.guests.invitation.send.success(email: invitation.email),
        );
        context.pop(invitation);
      },
      getErrorMessage: (error) => guestErrorMessage(error, byStatusCode: errorMessageByStatusCode),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MainAppBar(title: t.guests.invitation.title),
      body: Padding(
        padding: screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 24,
            children: [
              FormSection(
                title: t.common.email,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    validator: validateEmail,
                    onChanged: (email) => setState(() => _email = email),
                  ),
                ],
              ),
              FormSection(
                title: t.divisions.division,
                children: [
                  widget.divisions.length == 1
                      ? Text(widget.divisions.single.shortDisplayName, style: theme.textTheme.bodyLarge)
                      : Selection(
                          selected: _division,
                          setSelected: (division) => setState(() => _division = division),
                          items: widget.divisions,
                          compare: (division1, division2) => division1.divisionKey == division2.divisionKey,
                          filter: (division, query) => division.matches(query),
                          itemAsString: (division) => division.shortDisplayName,
                          label: t.divisions.division,
                          validator: (division) => division == null ? t.guests.validation.divisionRequired : null,
                        ),
                ],
              ),
              Hint(text: t.guests.invitation.validityHint),
              FilledButton.icon(
                icon: Icon(Icons.email_outlined),
                onPressed: _sendInvitation,
                label: Text(t.guests.invitation.invite),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
