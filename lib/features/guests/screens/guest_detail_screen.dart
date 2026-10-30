import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/app/widgets/section_card.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/features/guests/widgets/action_buttons.dart';
import 'package:gruene_app/features/guests/widgets/guest_status_chip.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestDetailExtra {
  final Division division;
  final void Function(Guest updated) onChanged;

  const GuestDetailExtra({required this.division, required this.onChanged});
}

class GuestDetailScreen extends StatelessWidget {
  final String guestId;
  final GuestDetailExtra extra;

  const GuestDetailScreen({super.key, required this.guestId, required this.extra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.guests.guest),
      body: FutureLoadingScreen(
        load: () => GetIt.I<GuestApiService>().getGuest(guestId),
        buildChild: (guest, loading) => _GuestDetailView(
          guest: guest,
          division: extra.division,
          onChanged: (updated) {
            extra.onChanged(updated);
            loading.refresh();
          },
        ),
      ),
    );
  }
}

class _GuestDetailView extends StatelessWidget {
  final GuestDetail guest;
  final Division division;
  final void Function(Guest updated) onChanged;

  const _GuestDetailView({required this.guest, required this.division, required this.onChanged});

  void onGuestChanged(Guest guest) => onChanged(guest);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = guest.email;
    final expiresOn = guest.expiresOn;
    final renewals = guest.history.where((entry) => entry.type == GuestHistoryType.renewed).length;
    final expired = expiresOn == null || !expiresOn.isAfter(DateTime.now());

    return ExpandingScrollView(
      padding: EdgeInsets.only(bottom: bottomScreenPaddingValue),
      spacing: 16,
      children: [
        ListTile(
          title: Text(guest.fullName, style: theme.textTheme.titleLarge),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                if (email != null) Text(email, style: theme.textTheme.bodyLarge),
                Text(division.shortDisplayName, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          trailing: GuestStatusChip(status: guest.status),
          tileColor: theme.colorScheme.surface,
          contentPadding: screenPadding.copyWith(bottom: 16),
        ),
        ListTile(
          title: Text(
            expired ? t.guests.expiredAt : t.guests.validUntil,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              expired ? t.guests.expiredAt : t.guests.validUntil,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          tileColor: theme.colorScheme.surface,
        ),
        SectionCard(
          title: t.guests.validUntil,
          children: [
            if (expiresOn != null)
              SectionCardListItem(
                title: expired ? t.guests.expiredAt : t.guests.validUntil,
                value: expired
                    ? expiresOn.formattedDate
                    : '${expiresOn.formattedDate} · ${t.guests.daysLeft(days: expiresOn.daysUntil)}',
              ),
            SectionCardListItem(
              title: t.guests.renewals.title,
              value: t.guests.renewals.times(count: renewals),
            ),
          ],
        ),
        // SectionCard(
        //   title: t.guests.origin,
        //   children: [
            // SectionCardListItem(title: t.guests.invitedBy, value: guest.invitedBy.name ?? t.common.unknown),
            // SectionCardListItem(title: t.guests.invitedAt, value: guest.invitedAt.formattedDate),
            // SectionCardListItem(title: t.guests.acceptedAt, value: guest.activatedAt.formattedDate),
        //   ],
        // ),
        SectionCard(
          title: t.guests.history.title,
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
        Spacer(),
        ActionButtons(actions: guest.toGuest().actions(context), onSuccess: onChanged),
      ],
    );
  }
}
