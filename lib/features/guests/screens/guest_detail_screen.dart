import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/section_card.dart';
import 'package:gruene_app/app/widgets/small_button_spinner.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/features/guests/utils/guest_actions.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/features/guests/widgets/guest_status_chip.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestDetailExtra {
  final Division? division;
  final void Function(Guest updated) onChanged;

  const GuestDetailExtra({required this.division, required this.onChanged});
}

class GuestDetailScreen extends StatelessWidget {
  final String userId;
  final GuestDetailExtra? extra;

  const GuestDetailScreen({super.key, required this.userId, this.extra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.guests.guest),
      body: FutureLoadingScreen(
        load: () => GetIt.I<GuestApiService>().getGuest(userId),
        buildChild: (guest, loading) => _GuestDetailView(
          guest: guest,
          division: extra?.division,
          onChanged: (updated) {
            extra?.onChanged(updated);
            // The history changed too, so it is loaded again.
            loading.refresh();
          },
        ),
      ),
    );
  }
}

class _GuestDetailView extends StatefulWidget {
  final GuestDetail guest;
  final Division? division;
  final void Function(Guest updated) onChanged;

  const _GuestDetailView({required this.guest, required this.division, required this.onChanged});

  @override
  State<_GuestDetailView> createState() => _GuestDetailViewState();
}

class _GuestDetailViewState extends State<_GuestDetailView> {
  GuestAction? _running;

  Future<void> _run(GuestAction action) async {
    if (_running != null) return;
    final updated = await action.run(
      context,
      widget.guest.toGuest(),
      onConfirmed: () => setState(() => _running = action),
    );
    if (!mounted) return;
    setState(() => _running = null);
    if (updated != null) widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guest = widget.guest;
    final email = guest.email;
    final expiresOn = guest.expiresOn;
    final renewals = guest.history.where((entry) => entry.type == GuestHistoryType.renewed).length;
    final expired = expiresOn == null || !expiresOn.isAfter(DateTime.now());

    return SingleChildScrollView(
      padding: verticalScreenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(guest.fullName, style: theme.textTheme.titleLarge),
                if (email != null) Text(email, style: theme.textTheme.bodySmall),
                GuestStatusChip(status: guest.status),
              ],
            ),
          ),
          SectionCard(
            title: t.guests.access,
            children: [
              SectionCardListItem(
                title: t.guests.division,
                value: widget.division?.shortDisplayName ?? guest.divisionKey,
              ),
              if (expiresOn != null)
                SectionCardListItem(
                  title: expired ? t.guests.accessExpiredAt : t.guests.accessValidUntil,
                  value: expired
                      ? expiresOn.formattedDate
                      : '${expiresOn.formattedDate} · ${t.guests.daysLeft(days: _daysUntil(expiresOn))}',
                ),
              SectionCardListItem(
                title: t.guests.renewals,
                value: renewals == 0 ? t.guests.neverRenewed : t.guests.renewedTimes(count: renewals),
              ),
            ],
          ),
          SectionCard(
            title: t.guests.origin,
            children: [
              SectionCardListItem(title: t.guests.invitedBy, value: guest.invitedBy.name ?? t.common.unknown),
              SectionCardListItem(title: t.guests.invitedAt, value: guest.invitedAt.formattedDate),
              SectionCardListItem(title: t.guests.acceptedAt, value: guest.activatedAt.formattedDate),
            ],
          ),
          SectionCard(
            title: t.guests.history,
            children: guest.history.map(
              (entry) => ListTile(
                title: Text(entry.type.label),
                subtitle: Text(
                  [entry.at.formattedDate, entry.by?.name].nonNulls.join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ),
          Column(
            children: GuestAction.availableFor(guest.status)
                .map(
                  (action) => TextListItem(
                    title: action.label,
                    onPress: () => _run(action),
                    trailing: _running == action
                        ? SmallButtonSpinner()
                        : Icon(
                            action.icon,
                            color: action == GuestAction.block ? theme.colorScheme.error : theme.disabledColor,
                          ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

int _daysUntil(DateTime date) =>
    DateUtils.dateOnly(date.toLocal()).difference(DateUtils.dateOnly(DateTime.now())).inDays;
