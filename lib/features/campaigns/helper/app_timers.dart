import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/features/campaigns/helper/background_timer.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';

class AppTimers {
  static BackgroundTimer getCampaignActionCacheTimer() {
    return BackgroundTimer(onTimer: _flushCacheData);
  }

  static void _flushCacheData() async {
    var authRepo = AuthRepository();
    if (await authRepo.getAccessToken() != null) {
      GetIt.I<CampaignActionCache>().flushCache();
    }
  }
}
