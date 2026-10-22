import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/form_section.dart';
import 'package:gruene_app/app/widgets/hint.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/app/widgets/small_button_spinner.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

// Only catches obvious typos, the API checks the address properly.
final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class GuestInviteScreen extends StatefulWidget {
  final List<Division> divisions;

  const GuestInviteScreen({super.key, required this.divisions});

  @override
  State<GuestInviteScreen> createState() => _GuestInviteScreenState();
}

class _GuestInviteScreenState extends State<GuestInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  Division? _division;
  bool _divisionMissing = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.divisions.length == 1) _division = widget.divisions.single;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return t.guests.validation.emailRequired;
    if (!_emailPattern.hasMatch(email)) return t.guests.validation.emailInvalid;
    return null;
  }

  Future<void> _send() async {
    final emailValid = _formKey.currentState!.validate();
    final division = _division;
    setState(() => _divisionMissing = division == null);
    if (!emailValid || division == null) return;

    setState(() => _sending = true);
    try {
      final invitation = await GetIt.I<GuestApiService>().createInvitation(
        email: _emailController.text.trim(),
        divisionKey: division.divisionKey,
      );
      if (!mounted) return;
      showSnackBar(
        context: context,
        text: t.guests.sent(email: invitation.email),
      );
      context.pop(invitation);
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      final message = guestErrorMessage(
        error,
        byStatusCode: {400: t.guests.validation.emailInvalid, 409: t.guests.error.openInvitationExists},
      );
      showSnackBar(context: context, text: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MainAppBar(title: t.guests.invite),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: screenPadding,
          children: [
            FormSection(
              title: t.guests.email,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                ),
              ],
            ),
            SizedBox(height: 24),
            FormSection(
              title: t.guests.division,
              spacing: 8,
              children: [
                if (widget.divisions.length == 1)
                  Text(widget.divisions.single.shortDisplayName, style: theme.textTheme.bodyLarge)
                else
                  Selection(
                    selected: _division,
                    setSelected: (division) => setState(() {
                      _division = division;
                      _divisionMissing = false;
                    }),
                    items: widget.divisions,
                    compare: (division1, division2) => division1.divisionKey == division2.divisionKey,
                    filter: (division, query) => division.matches(query),
                    itemAsString: (division) => division.shortDisplayName,
                    label: t.guests.division,
                  ),
                if (_divisionMissing)
                  Text(
                    t.guests.validation.divisionRequired,
                    style: theme.textTheme.bodySmall?.apply(color: theme.colorScheme.error),
                  ),
              ],
            ),
            SizedBox(height: 24),
            Hint(text: t.guests.validityHint),
            SizedBox(height: 24),
            FilledButton(
              onPressed: _sending ? null : _send,
              child: _sending ? SmallButtonSpinner() : Text(t.guests.send),
            ),
          ],
        ),
      ),
    );
  }
}
