import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';

class AddressFieldDetail extends StatelessWidget {
  const AddressFieldDetail({super.key, required this.street, required this.houseNumber});

  final String street;
  final String houseNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addressTextStyle = theme.textTheme.labelSmall?.apply(color: ThemeColors.secondary, fontWeightDelta: 3);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 100,
            child: Text(street, textAlign: TextAlign.right, style: addressTextStyle, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 3),
          Text(houseNumber, style: addressTextStyle),
        ],
      ),
    );
  }
}
