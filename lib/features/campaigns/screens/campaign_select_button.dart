import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/screens/campaign_select_widget.dart';

class CampaignSelectButton extends StatelessWidget {
  const CampaignSelectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.how_to_vote_outlined),
      onPressed: () => _showCampaignSelectDialog(context),
    );
  }

  void _showCampaignSelectDialog(BuildContext context) async {
    await showCampaignSelectDialog(context);
  }
}
