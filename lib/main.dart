import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_keycloak_authenticator/flutter_keycloak_authenticator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/router.dart';
import 'package:gruene_app/app/services/api/api_core.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/ip/ip_service.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/services/push_notifications/handlers/notification_handlers.dart';
import 'package:gruene_app/app/services/push_notifications/notification_message_type.dart';
import 'package:gruene_app/app/services/push_notifications/push_notification_listener.dart';
import 'package:gruene_app/app/services/push_notifications/push_notification_service.dart';
import 'package:gruene_app/app/services/services.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/file_cache_manager.dart';
import 'package:gruene_app/app/utils/profile_feature_checker.dart';
import 'package:gruene_app/app/utils/visual_identifier_helper.dart';
import 'package:gruene_app/app/widgets/clean_layout.dart';
import 'package:gruene_app/features/campaigns/controllers/map_screen_controller.dart';
import 'package:gruene_app/features/campaigns/controllers/team_refresh_controller.dart';
import 'package:gruene_app/features/campaigns/core/cache/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/core/notifications/campaign_notification_handlers.dart';
import 'package:gruene_app/features/campaigns/helper/app_timers.dart';
import 'package:gruene_app/features/campaigns/helper/background_timer.dart';
import 'package:gruene_app/features/events/bloc/events_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/news/bloc/bookmark_cubit.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_bloc.dart';
import 'package:gruene_app/features/settings/bloc/push_notifications/push_notification_settings_event.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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

  final secureStorage = const FlutterSecureStorage();
  GetIt.I.registerSingleton<FlutterSecureStorage>(secureStorage);

  final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  GetIt.I.registerFactory<AuthenticatorService>(
    () => AuthenticatorService(storage: FlutterSecureStorageAdapter(secureStorage)),
  );
  GetIt.I.registerSingleton<IpService>(IpService());

  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();
  GetIt.I.registerSingleton<PushNotificationService>(pushNotificationService);

  final pushNotificationListener = PushNotificationListener(navigatorKey);
  await pushNotificationListener.initialize();
  GetIt.I.registerSingleton<PushNotificationListener>(pushNotificationListener);

  AppSettings.register();

  // Warning: The gruene api singleton depends on the auth repository which depends on the authenticator singleton
  // Therefore this should be last
  GetIt.I.registerSingleton<GrueneApi>(await createGrueneApiClient());
  GetIt.I.registerSingleton<ProfileFeatureChecker>(ProfileFeatureChecker());
  GetIt.I.registerFactory<NominatimService>(() => NominatimService(countryCode: t.campaigns.search.country_code));
  GetIt.I.registerSingleton<CampaignActionCache>(CampaignActionCache());
  GetIt.I.registerSingleton<OpenInvitationCampaignValueStore>(OpenInvitationCampaignValueStore());
  GetIt.I.registerSingleton<ActiveCampaignNotifier>(ActiveCampaignNotifier());
  GetIt.I.registerSingleton<NewCampaignNotifier>(NewCampaignNotifier());
  initializeTimers();
  GetIt.I.registerSingleton<FileManager>(FileManager());
  GetIt.I.registerSingleton<MapScreenController>(MapScreenController(), instanceName: PoiServiceType.poster.toString());
  GetIt.I.registerSingleton<MapScreenController>(MapScreenController(), instanceName: PoiServiceType.flyer.toString());
  GetIt.I.registerSingleton<MapScreenController>(MapScreenController(), instanceName: PoiServiceType.door.toString());
  GetIt.I.registerSingleton<TeamRefreshController>(TeamRefreshController());
  GetIt.I.registerSingleton<VisualIdentifierHelper>(VisualIdentifierHelper());
  initializeApiServices();
  initializeNotificationHandlers();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(TranslationProvider(child: MyApp(navigatorKey: navigatorKey)));
}

void initializeTimers() {
  GetIt.I.registerSingleton<BackgroundTimer>(
    AppTimers.getCampaignActionCacheTimer(),
    instanceName: 'campaignActionCacheTimer',
  );
  GetIt.I.registerSingleton<BackgroundTimer>(AppTimers.getOpenInvitationTimer(), instanceName: 'openInvitationTimer');
  GetIt.I.registerSingleton<BackgroundTimer>(
    AppTimers.getEnforceActiveCampaignTimer(),
    instanceName: 'enforceActiveCampaignTimer',
  );
  GetIt.I.registerSingleton<BackgroundTimer>(
    AppTimers.getCheckForNewCampaignsTimer(),
    instanceName: 'checkForNewCampaignsTimer',
  );
}

void initializeNotificationHandlers() {
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => NewsNotificationHandler(),
    instanceName: NotificationMessageType.news.toString(),
  );
  GetIt.I.registerFactory<BaseNotificationHandler>(
    () => MfaNotificationHandler(),
    instanceName: NotificationMessageType.mfa.toString(),
  );
  registerCampaignNotificationHandlers();
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;

    if (shortestSide < 640) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authRepository)..add(CheckTokenRequested())),
        BlocProvider(create: (context) => EventsBloc()..add(LoadEvents(force: true))),
        BlocProvider(create: (context) => MfaBloc()..add(InitMfa())),
        BlocProvider(create: (context) => PushNotificationSettingsBloc()..add(LoadSettings())),
        BlocProvider(create: (context) => BookmarkCubit()),
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
                initialMessage.processMessage(navigatorKey.currentContext);
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
