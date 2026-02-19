import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/features/campaigns/helper/background_timer.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';

class AppTimers {
  static BackgroundTimer getCampaignActionCacheTimer() {
    return BackgroundTimer(onTimer: _flushCacheData);
  }

  static BackgroundTimer getOpenInvitationTimer() {
    return BackgroundTimer(onTimer: _reloadOpenInvitations, runEvery: Duration(minutes: 1));
  }

  static void _flushCacheData() async {
    var authRepo = AuthRepository();
    if (await authRepo.getAccessToken() != null) {
      GetIt.I<CampaignActionCache>().flushCache();
    }
  }

  static Future<void> _reloadOpenInvitations() async {
    var authRepo = AuthRepository();
    if (await authRepo.getAccessToken() != null) {
      GetIt.I<CampaignValueStore>().reloadOpenInvitations();
    }
  }
}

class CampaignValueStore extends ChangeNotifier {
  int _openInvitationCount = 0;
  int get openInvitations => _openInvitationCount;

  void reloadOpenInvitations() async {
    var openInvitations = await GetIt.I<GrueneApiTeamsService>().getOpenInvitations();
    if (openInvitations.length != _openInvitationCount) {
      _openInvitationCount = openInvitations.length;
      notifyListeners();
    }
  }
}
