import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/section_card.dart';
import 'package:gruene_app/app/widgets/small_button_spinner.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestInvitationDetailExtra {
  final GuestInvitation invitation;
  final Division? division;
  final void Function(GuestInvitation updated) onChanged;

  const GuestInvitationDetailExtra({required this.invitation, required this.division, required this.onChanged});
}

class GuestInvitationDetailScreen extends StatefulWidget {
  final GuestInvitationDetailExtra extra;

  const GuestInvitationDetailScreen({super.key, required this.extra});

  @override
  State<GuestInvitationDetailScreen> createState() => _GuestInvitationDetailScreenState();
}

enum _Action { resend, revoke }

class _GuestInvitationDetailScreenState extends State<GuestInvitationDetailScreen> {
  late GuestInvitation _invitation;
  _Action? _running;

  @override
  void initState() {
    super.initState();
    _invitation = widget.extra.invitation;
  }

  Future<void> _run(_Action action, Future<GuestInvitation> Function() request, String successText) async {
    if (_running != null) return;
    setState(() => _running = action);
    try {
      final updated = await request();
      if (!mounted) return;
      setState(() => _invitation = updated);
      widget.extra.onChanged(updated);
      showSnackBar(context: context, text: successText);
    } catch (error) {
      if (!mounted) return;
      final conflict = action == _Action.resend ? t.guests.error.resendConflict : t.guests.error.notOpen;
      showSnackBar(
        context: context,
        text: guestErrorMessage(error, byStatusCode: {409: conflict}),
      );
    } finally {
      if (mounted) setState(() => _running = null);
    }
  }

  Future<void> _resend() =>
      _run(_Action.resend, () => GetIt.I<GuestApiService>().resendInvitation(_invitation.id), t.guests.resent);

  Future<void> _revoke() async {
    if (await showRevokeConfirmationDialog(context) != true) return;
    await _run(_Action.revoke, () async {
      await GetIt.I<GuestApiService>().revokeInvitation(_invitation.id);
      return _invitation.copyWith(status: GuestInvitationStatus.revoked);
    }, t.guests.revoked);
  }

  Widget _trailing(_Action action, IconData icon) =>
      _running == action ? SmallButtonSpinner() : Icon(icon, color: Theme.of(context).disabledColor);

  @override
  Widget build(BuildContext context) {
    final invitation = _invitation;
    final division = widget.extra.division;
    final status = invitation.status;

    return Scaffold(
      appBar: MainAppBar(title: t.guests.invitation),
      body: SingleChildScrollView(
        padding: verticalScreenPadding,
        child: Column(
          spacing: 16,
          children: [
            SectionCard(
              children: [
                SectionCardListItem(title: t.guests.email, value: invitation.email),
                SectionCardListItem(
                  title: t.guests.division,
                  value: division?.shortDisplayName ?? invitation.divisionKey,
                ),
                SectionCardListItem(title: t.guests.status, value: status.label),
                SectionCardListItem(title: t.guests.invitedAt, value: invitation.createdAt.formattedDate),
                SectionCardListItem(title: t.guests.invitedBy, value: invitation.invitedBy.name ?? t.common.unknown),
                if (status == GuestInvitationStatus.open || status == GuestInvitationStatus.expired)
                  SectionCardListItem(
                    title: status == GuestInvitationStatus.expired ? t.guests.expiredAt : t.guests.expiresAt,
                    value: invitation.expiresAt.formattedDateTime,
                  ),
              ],
            ),
            if (status == GuestInvitationStatus.open)
              Column(
                children: [
                  TextListItem(
                    title: t.guests.resend,
                    onPress: _resend,
                    trailing: _trailing(_Action.resend, Icons.send),
                  ),
                  TextListItem(
                    title: t.guests.revoke,
                    onPress: _revoke,
                    trailing: _trailing(_Action.revoke, Icons.block),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showRevokeConfirmationDialog(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(t.guests.confirmRevoke.title, style: theme.textTheme.titleLarge),
      content: Text(t.guests.confirmRevoke.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: EdgeInsets.all(8),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.common.actions.cancel)),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(t.guests.confirmRevoke.confirm)),
      ],
    );
  },
);
