import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/features/campaigns/controllers/team_refresh_controller.dart';

part 'base_notification_handler.dart';
part 'news_notification_handler.dart';
part 'team_notification_handler.dart';
part 'team_top10_notification_handler.dart';
part 'notification_constants.dart';
