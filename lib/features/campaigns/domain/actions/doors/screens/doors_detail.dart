import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_detail_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/address_field_detail.dart';
import 'package:gruene_app/i18n/translations.g.dart';

/// Detail of a door entry, shown in a map popover that takes the size of this content.
class DoorsDetail extends StatelessWidget {
  final DoorDetailModel poi;

  const DoorsDetail({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelTextStyle = theme.textTheme.labelSmall?.apply(color: Colors.black);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AddressFieldDetail(street: poi.address.street, houseNumber: poi.address.houseNumber),
        _countRow(t.campaigns.door.conversations, poi.conversations, labelTextStyle),
        Container(height: 1.5, color: ThemeColors.textLight),
        _countRow(t.campaigns.door.materialOnly, poi.materialOnly, labelTextStyle),
        Container(height: 1.5, color: ThemeColors.textLight),
      ],
    );
  }

  Widget _countRow(String label, int count, TextStyle? style) {
    return Padding(
      padding: EdgeInsets.only(left: 2, right: 2, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(count.toString(), style: style),
          ),
        ],
      ),
    );
  }
}
