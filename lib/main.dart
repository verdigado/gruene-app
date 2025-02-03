import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/router.dart';
import 'package:gruene_app/app/services/gruene_api_campaigns_statistics_service.dart';
import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/app/services/gruene_api_door_service.dart';
import 'package:gruene_app/app/services/gruene_api_flyer_service.dart';
import 'package:gruene_app/app/services/gruene_api_poster_service.dart';
import 'package:gruene_app/app/services/ip_service.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/app/services/secure_storage_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/clean_layout.dart';
import 'package:gruene_app/features/campaigns/helper/app_settings.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache_timer.dart';
import 'package:gruene_app/features/campaigns/helper/file_cache_manager.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/domain/mfa_factory.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:keycloak_authenticator/api.dart';
import 'package:timeago/timeago.dart' as timeago;

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  final locale = await LocaleSettings.useDeviceLocale();

  if (locale.languageCode == 'de') {
    timeago.setLocaleMessages('de', timeago.DeMessages());
  } else {
    timeago.setLocaleMessages('en', timeago.EnMessages());
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  registerSecureStorage();
  GetIt.I.registerSingleton<AppSettings>(AppSettings());
  GetIt.I.registerFactory<AuthenticatorService>(MfaFactory.create);
  GetIt.I.registerSingleton<IpService>(IpService());
  // Warning: The gruene api singleton depends on the auth repository which depends on the authenticator singleton
  // Therefore this should be last
  GetIt.I.registerSingleton<GrueneApi>(await createGrueneApiClient());
  GetIt.I.registerFactory<NominatimService>(() => NominatimService(countryCode: t.campaigns.search.country_code));
  GetIt.I.registerSingleton<CampaignActionCache>(CampaignActionCache());
  GetIt.I.registerSingleton<CampaignActionCacheTimer>(CampaignActionCacheTimer());
  GetIt.I.registerSingleton<FileManager>(FileManager());

  GetIt.I.registerFactory<GrueneApiPosterService>(() => GrueneApiPosterService());
  GetIt.I.registerFactory<GrueneApiDoorService>(() => GrueneApiDoorService());
  GetIt.I.registerFactory<GrueneApiFlyerService>(() => GrueneApiFlyerService());
  GetIt.I.registerFactory<GrueneApiCampaignsStatisticsService>(() => GrueneApiCampaignsStatisticsService());

  WidgetsFlutterBinding.ensureInitialized();

  // setupCachePeriodicFlushing();

  runApp(TranslationProvider(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository)..add(CheckTokenRequested()),
        ),
        BlocProvider(
          create: (context) => MfaBloc()..add(InitMfa()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final router = createAppRouter(context);
              final isLoginLoading = authState is AuthLoading;

              // Prevent flickering if current login state is not yet known
              if (isLoginLoading) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: appTheme,
                  home: CleanLayout(showAppBar: false),
                );
              }

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
