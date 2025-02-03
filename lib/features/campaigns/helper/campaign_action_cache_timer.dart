import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';

class CampaignActionCacheTimer {
  late Timer timer;

  CampaignActionCacheTimer() {
    timer = Timer.periodic(Duration(minutes: 5), (timer) => _flushData());

    // initial flush
    Future.delayed(Duration(seconds: 5), () => Timer.run(_flushData));
  }

  void _flushData() async {
    var authRepo = AuthRepository();
    if (await authRepo.getAccessToken() != null) {
      GetIt.I<CampaignActionCache>().flushCache();
    }
  }
}
