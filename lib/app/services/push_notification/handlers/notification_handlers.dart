import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/services/push_notification/notification_message_type.dart';
import 'package:gruene_app/app/utils/logger.dart';

part 'base_notification_handler.dart';
part 'mfa_notification_handler.dart';
part 'news_notification_handler.dart';
part 'notification_constants.dart';
part 'notification_response_handling.dart';
part 'remote_message_handling.dart';
