import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/router.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_action_area_service.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_statistics_service.dart';
import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/app/services/gruene_api_divisions_service.dart';
import 'package:gruene_app/app/services/gruene_api_door_service.dart';
import 'package:gruene_app/app/services/gruene_api_experience_area_service.dart';
import 'package:gruene_app/app/services/gruene_api_flyer_service.dart';
import 'package:gruene_app/app/services/gruene_api_poster_service.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/services/gruene_api_route_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/services/gruene_api_user_service.dart';
import 'package:gruene_app/app/services/ip_service.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/app/services/notification_message_type.dart';
import 'package:gruene_app/app/services/push_notification_listener.dart';
import 'package:gruene_app/app/services/push_notification_service.dart';
import 'package:gruene_app/app/services/secure_storage_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/profile_feature_checker.dart';
import 'package:gruene_app/app/widgets/clean_layout.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache_timer.dart';
import 'package:gruene_app/features/campaigns/helper/file_cache_manager.dart';
import 'package:gruene_app/features/events/bloc/events_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/domain/mfa_factory.dart';
import 'package:gruene_app/features/news/bloc/bookmark_bloc.dart';
import 'package:gruene_app/features/news/bloc/bookmark_event.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_bloc.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_event.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:keycloak_authenticator/api.dart';
import 'package:rrule/rrule.dart';
import 'package:timeago/timeago.dart' as timeago;

late RruleL10n rruleL10n;

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final locale = await LocaleSettings.useDeviceLocale();
  Intl.defaultLocale = locale.underscoreTag;
  await initializeDateFormatting();
  timeago.setLocaleMessages(Config.defaultLanguageCode, timeago.DeMessages());
  rruleL10n = await RruleL10nDe.create();

  registerSecureStorage();

  final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  GetIt.I.registerFactory<AuthenticatorService>(MfaFactory.create);
  GetIt.I.registerSingleton<IpService>(IpService());

  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();
  GetIt.I.registerSingleton<PushNotificationService>(pushNotificationService);

  final pushNotificationListener = PushNotificationListener(navigatorKey);
  await pushNotificationListener.initialize();
  GetIt.I.registerSingleton<PushNotificationListener>(pushNotificationListener);

  GetIt.I.registerSingleton<AppSettings>(AppSettings());

  // Warning: The gruene api singleton depends on the auth repository which depends on the authenticator singleton
  // Therefore this should be last
  GetIt.I.registerSingleton<GrueneApi>(await createGrueneApiClient());
  GetIt.I.registerSingleton<ProfileFeatureChecker>(ProfileFeatureChecker());
  GetIt.I.registerFactory<NominatimService>(() => NominatimService(countryCode: t.campaigns.search.country_code));
  GetIt.I.registerSingleton<CampaignActionCache>(CampaignActionCache());
  GetIt.I.registerSingleton<CampaignActionCacheTimer>(CampaignActionCacheTimer());
  GetIt.I.registerSingleton<FileManager>(FileManager());
  GetIt.I.registerFactory<GrueneApiPosterService>(() => GrueneApiPosterService());
  GetIt.I.registerFactory<GrueneApiDoorService>(() => GrueneApiDoorService());
  GetIt.I.registerFactory<GrueneApiFlyerService>(() => GrueneApiFlyerService());
  GetIt.I.registerFactory<GrueneApiRouteService>(() => GrueneApiRouteService());
  GetIt.I.registerFactory<GrueneApiActionAreaService>(() => GrueneApiActionAreaService());
  GetIt.I.registerFactory<GrueneApiExperienceAreaService>(() => GrueneApiExperienceAreaService());
  GetIt.I.registerFactory<GrueneApiCampaignsStatisticsService>(() => GrueneApiCampaignsStatisticsService());
  GetIt.I.registerFactory<GrueneApiCampaignService>(() => GrueneApiCampaignService());
  GetIt.I.registerFactory<GrueneApiTeamsService>(() => GrueneApiTeamsService());
  GetIt.I.registerFactory<GrueneApiDivisionsService>(() => GrueneApiDivisionsService());
  GetIt.I.registerFactory<GrueneApiProfileService>(() => GrueneApiProfileService());
  GetIt.I.registerFactory<GrueneApiUserService>(() => GrueneApiUserService());

  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => NewsNotificationHandler(),
    instanceName: NotificationMessageType.news.toString(),
  );
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => TeamNotificationHandler(),
    instanceName: NotificationMessageType.teamMembershipUpdate.toString(),
  );
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => TeamNotificationHandler(),
    instanceName: NotificationMessageType.routeAssignmentUpdate.toString(),
  );
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => TeamNotificationHandler(),
    instanceName: NotificationMessageType.areaAssignmentUpdate.toString(),
  );

  WidgetsFlutterBinding.ensureInitialized();

  // setupCachePeriodicFlushing();

  runApp(TranslationProvider(child: MyApp(navigatorKey: navigatorKey)));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authRepository)..add(CheckTokenRequested())),
        BlocProvider(create: (context) => EventsBloc()..add(LoadEvents(force: true))),
        BlocProvider(create: (context) => MfaBloc()..add(InitMfa())),
        BlocProvider(create: (context) => PushNotificationSettingsBloc()..add(LoadSettings())),
        BlocProvider<BookmarkBloc>(create: (context) => BookmarkBloc()..add(LoadBookmarks())),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final router = createAppRouter(context, navigatorKey);
              final isLoginLoading = authState is AuthLoading;

              // Prevent flickering if current login state is not yet known
              if (isLoginLoading) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: appTheme,
                  home: CleanLayout(showAppBar: false),
                );
              }

              SchedulerBinding.instance.addPostFrameCallback((_) {
                final initialMessage = GetIt.I<PushNotificationListener>().initialMessage;
                if (initialMessage == null) {
                  return;
                }
                var notificationHandler = initialMessage.getNotificationHandler();
                notificationHandler.processMessage(initialMessage, navigatorKey.currentContext);
                // var routerLocation = '';
                // switch (initialMessage.getMessageType()) {
                //   case NotificationMessageType.news:
                //     routerLocation = '${RouteLocations.getRoute([RouteLocations.news])}/${initialMessage.getNewsId()}';
                //     break;
                //   case NotificationMessageType.teamMembershipUpdate:
                //     routerLocation = RouteLocations.getRoute([
                //       RouteLocations.campaigns,
                //       RouteLocations.campaignTeamDetail,
                //     ]);
                //     break;
                //   default:
                //     return;
                // }

                // final newsId = GetIt.I<PushNotificationListener>().initialMessage.getNewsId();
                // final context = navigatorKey.currentContext;
                // if (newsId != null && context != null) {
                //   GoRouter.of(context).go(routerLocation);
                // }
              });

              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                locale: TranslationProvider.of(context).flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                routeInformationParser: router.routeInformationParser,
                routerDelegate: router.routerDelegate,
                routeInformationProvider: router.routeInformationProvider,
                theme: appTheme,
              );
            },
          );
        },
      ),
    );
  }
}
