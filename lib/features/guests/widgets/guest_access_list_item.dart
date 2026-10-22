import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

/// Shown only to people who may invite guests to at least one division
class GuestAccessListItem extends StatefulWidget {
  const GuestAccessListItem({super.key});

  @override
  State<GuestAccessListItem> createState() => _GuestAccessListItemState();
}

class _GuestAccessListItemState extends State<GuestAccessListItem> {
  late final Future<List<Division>> _divisions;

  @override
  void initState() {
    super.initState();
    _divisions = GetIt.I<GuestApiService>().getInvitationDivisions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _divisions,
      builder: (context, snapshot) {
        if (snapshot.data?.isNotEmpty != true) return SizedBox.shrink();
        return TextListItem(
          title: t.guests.guestAccess,
          onPress: () => context.pushNested(RouteLocations.guestInvitations),
        );
      },
    );
  }
}
