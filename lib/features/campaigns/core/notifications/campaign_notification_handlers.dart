import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/services/push_notification/handlers/notification_handlers.dart';
import 'package:gruene_app/app/services/push_notification/notification_message_type.dart';
import 'package:gruene_app/features/campaigns/controllers/team_refresh_controller.dart';
import 'package:gruene_app/features/campaigns/helper/challenge_helper.dart';

part 'handlers/challenge_membership_target_reached_handler.dart';
part 'handlers/challenge_membership_time_elapsed_handler.dart';
part 'handlers/team_notification_handler.dart';
part 'handlers/team_top10_notification_handler.dart';

void registerCampaignNotificationHandlers() {
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => TeamNotificationHandler(),
    instanceName: NotificationMessageType.teamMembershipUpdate.toString(),
  );
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => TeamNotificationHandler(), // we use the TeamNotificationHandler as currently no other handling is required
    instanceName: NotificationMessageType.routeAssignmentUpdate.toString(),
  );
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => TeamNotificationHandler(), // we use the TeamNotificationHandler as currently no other handling is required
    instanceName: NotificationMessageType.areaAssignmentUpdate.toString(),
  );
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => TeamTop10NotificationHandler(),
    instanceName: NotificationMessageType.teamTop10Update.toString(),
  );
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => ChallengeMembershipTimeElapsedHandler(),
    instanceName: NotificationMessageType.challengeMembershipTimeElapsed.toString(),
  );
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => ChallengeMembershipTargetReachedHandler(),
    instanceName: NotificationMessageType.challengeMembershipTargetReached.toString(),
  );
}
