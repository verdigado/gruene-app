import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/campaign_select_widget.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';

Future<void> showCampaignSelectDialog(BuildContext context, {bool enforceSelect = false}) async {
  if (CampaignSelectWidget.showCounter > 0) {
    // Prevent multiple dialogs from being opened at the same time
    return;
  }

  var isDismissible = !enforceSelect;

  final theme = Theme.of(context);
  while (true) {
    var selectCampaignResult = await showModalBottomSheet<CampaignSelectResult>(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: max(MediaQuery.of(context).viewInsets.bottom, DesignConstants.bottomPadding)),
        child: CampaignSelectWidget(
          mode: enforceSelect ? CampaignSelectMode.enforceSelect : CampaignSelectMode.normal,
          storeRecentSeenCampaigns: true,
        ),
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      useRootNavigator: true,
      backgroundColor: theme.colorScheme.surface,
    );
    if (enforceSelect &&
        (selectCampaignResult == null || !selectCampaignResult.success || selectCampaignResult.campaign == null)) {
      // If selection is enforced, we need to show the dialog again if the user dismissed it without selecting
      continue;
    }
    if (selectCampaignResult != null && selectCampaignResult.success) {
      // apply selection
      if (!context.mounted) return;
      switchCampaign(selectCampaignResult.campaign, context);
    }
    break;
  }
}

Future<String?> showCampaignSelectDialogForStatistics(
  BuildContext context,
  String? Function() getCurrentContextCampaignId,
) async {
  final theme = Theme.of(context);
  var selectCampaignResult = await showModalBottomSheet<CampaignSelectResult>(
    context: context,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: max(MediaQuery.of(context).viewInsets.bottom, DesignConstants.bottomPadding)),
      child: CampaignSelectWidget(
        mode: CampaignSelectMode.statistics,
        getCurrentContextCampaignId: getCurrentContextCampaignId,
      ),
    ),
    isScrollControlled: true,
    isDismissible: true,
    useRootNavigator: true,
    backgroundColor: theme.colorScheme.surface,
  );
  if (selectCampaignResult != null && selectCampaignResult.success) {
    return selectCampaignResult.campaign?.id;
  }
  return null;
}
