import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl_platform_interface/maplibre_gl_platform_interface.dart';

class Config {
  static String get appId => 'de.gruene.wkapp';
  static String get env => dotenv.env['ENV'] ?? 'production';
  static bool get isProduction => Config.env == 'production';
  static bool get isStaging => Config.env == 'staging';
  static bool get isDevelopment => Config.env == 'development';

  static String get grueneApiUrl => dotenv.env['GRUENE_API_URL']!;
  static String? get grueneApiAccessToken => dotenv.env['GRUENE_API_ACCESS_TOKEN'];

  static String get oidcCallbackPath => '${Config.appId}://oauthredirect';
  static String get oidcClientId => dotenv.env['OIDC_CLIENT_ID']!;
  static String get oidcIssuer => dotenv.env['OIDC_ISSUER']!;

  static String get maplibreUrl => dotenv.env['MAP_MAPLIBRE_URL']!;
  static String get addressSearchUrl => dotenv.env['MAP_ADDRESSSEARCH_URL']!;

  static String get ipV4ServiceUrl => dotenv.env['IP_V4_SERVICE_URL']!;
  static String get ipV6ServiceUrl => dotenv.env['IP_V6_SERVICE_URL']!;

  static String get defaultLocale => 'de_DE';
  static String get defaultLanguageCode => 'de';

  static DateTime? get poiFilterCutOffDate => DateFormat(dateFormat).tryParse(dotenv.env['POI_FILTER_DATE'] ?? '');

  static bool get androidFloss {
    // may be needed when building for f-droid store
    final configValue = dotenv.env['ANDROID_FLOSS'] ?? 'false';
    final value = bool.tryParse(configValue, caseSensitive: false);
    return value ?? false;
  }

  static LatLng centerGermany = LatLng(51.163361, 10.447683);
  static double germanyZoom = 4.5;
}
