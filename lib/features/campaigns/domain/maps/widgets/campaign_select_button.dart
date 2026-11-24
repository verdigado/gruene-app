import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/campaign_select_dialog.dart';
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';

class CampaignSelectButton extends StatefulWidget {
  const CampaignSelectButton({super.key});

  @override
  State<CampaignSelectButton> createState() => _CampaignSelectButtonState();
}

class _CampaignSelectButtonState extends State<CampaignSelectButton> {
  final _newCampaignNotifier = GetIt.I<NewCampaignNotifier>();

  @override
  void initState() {
    super.initState();
    _newCampaignNotifier.addListener(_onNewCampaignsChanged);
  }

  @override
  void dispose() {
    // the same function as added: a new closure would not be removed and keep this state alive
    _newCampaignNotifier.removeListener(_onNewCampaignsChanged);
    super.dispose();
  }

  void _onNewCampaignsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    var icon = const Icon(Icons.how_to_vote_outlined);
    return IconButton(
      icon: _newCampaignNotifier.newCampaignsAvailable ? Badge(child: icon) : icon,
      onPressed: () => _showCampaignSelectDialog(context),
    );
  }

  void _showCampaignSelectDialog(BuildContext context) async {
    await showCampaignSelectDialog(context);
  }
}
