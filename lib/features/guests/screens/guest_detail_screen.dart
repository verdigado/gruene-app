import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/detail_list_item.dart';
import 'package:gruene_app/app/widgets/status_tag.dart';
import 'package:gruene_app/features/guests/utils/guest_actions.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/features/guests/widgets/action_buttons.dart';
import 'package:gruene_app/features/guests/widgets/expiry_info.dart';
import 'package:gruene_app/features/guests/widgets/guest_history_timeline.dart';
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
        buildChild: (guest, loading) => GuestDetailView(
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

class GuestDetailView extends StatelessWidget {
  final GuestDetail guest;
  final Division division;
  final void Function(Guest updated) onChanged;

  const GuestDetailView({super.key, required this.guest, required this.division, required this.onChanged});

  void onGuestChanged(Guest guest) => onChanged(guest);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = guest.email;
    final renewals = guest.history.where((entry) => entry.type == GuestHistoryType.renewed).length;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  DetailListItem.header(
                    title: guest.fullName,
                    tag: StatusTag(label: guest.status.label, color: guest.status.color(theme)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        if (email != null) Text(email, style: theme.textTheme.bodyLarge),
                        Text(division.shortDisplayName, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  DetailListItem(
                    title: guest.status == GuestStatus.expired ? t.guests.expiredAt : t.guests.validUntil,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GuestExpiryInfo(guest: guest.toGuest()),
                        Text(t.guests.renewalCount(count: renewals)),
                      ],
                    ),
                  ),
                  DetailListItem(
                    title: t.guests.history.title,
                    child: GuestHistoryTimeline(entries: guest.history, guestName: guest.fullName),
                  ),
                ],
              ),
            ),
          ),
          ActionButtons(actions: guest.toGuest().actions(context), onSuccess: onChanged),
        ],
      ),
    );
  }
}
