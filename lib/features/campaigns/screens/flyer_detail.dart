import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_detail_model.dart';
import 'package:gruene_app/features/campaigns/widgets/address_field_detail.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class FlyerDetail extends StatelessWidget {
  final FlyerDetailModel poi;

  const FlyerDetail({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelTextStyle = theme.textTheme.labelSmall?.apply(color: Colors.black);
    return Column(
      children: [
        AddressFieldDetail(street: poi.address.street, houseNumber: poi.address.houseNumber),
        Container(
          padding: EdgeInsets.only(left: 2, right: 2, top: 6),
          child: Row(
            children: [
              Expanded(child: Text(t.campaigns.flyer.countFlyer, style: labelTextStyle)),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.only(left: 6),
                  child: Text(poi.flyerCount.toString(), style: labelTextStyle),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1.5, color: ThemeColors.textLight),
      ],
    );
  }
}
