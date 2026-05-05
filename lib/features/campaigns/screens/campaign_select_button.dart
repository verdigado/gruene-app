import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/features/campaigns/screens/campaign_select_widget.dart';

class CampaignSelectButton extends StatelessWidget {
  const CampaignSelectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(Icons.how_to_vote_outlined), onPressed: () => showCampaignSelectDialog(context));
  }

  void showCampaignSelectDialog(BuildContext context) async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: max(MediaQuery.of(context).viewInsets.bottom, DesignConstants.bottomPadding)),
        child: CampaignSelectWidget(),
      ),
      isScrollControlled: true,
      isDismissible: true,
      useRootNavigator: true,
      backgroundColor: theme.colorScheme.surface,
    );
  }
}
