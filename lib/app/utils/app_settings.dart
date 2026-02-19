import 'package:get_it/get_it.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_session_settings.dart';
import 'package:maplibre_gl_platform_interface/maplibre_gl_platform_interface.dart';

class AppSettings {
  var campaign = CampaignSessionSettings();
  ({LatLng lastPosition, double lastZoomLevel})? events;

  static void register() {
    GetIt.I.unregister<AppSettings>(disposingFunction: (appSetting) {});
    GetIt.I.registerSingleton<AppSettings>(AppSettings());
  }
}
