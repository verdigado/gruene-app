import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/features/campaigns/helper/background_timer.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';

class AppTimers {
  static BackgroundTimer getCampaignActionCacheTimer() {
    return BackgroundTimer(onTimer: _flushCacheData);
  }

  static BackgroundTimer getOpenInvitationTimer() {
    return BackgroundTimer(onTimer: _reloadOpenInvitations, runEvery: Duration(minutes: 1));
  }

  static BackgroundTimer getEnforceActiveCampaignTimer() {
    return BackgroundTimer(
      onTimer: _checkCurrentCampaignIsActive,
      runEvery: Duration(minutes: 1),
      initialRunDelay: Duration(seconds: 1),
    );
  }

  static BackgroundTimer getCheckForNewCampaignsTimer() {
    return BackgroundTimer(
      onTimer: _checkForNewCampaigns,
      runEvery: Duration(minutes: 5),
      initialRunDelay: Duration(seconds: 15),
    );
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
      GetIt.I<OpenInvitationCampaignValueStore>().reloadOpenInvitations();
    }
  }

  static void _checkCurrentCampaignIsActive() async {
    var authRepo = AuthRepository();
    if (await authRepo.getAccessToken() != null) {
      GetIt.I<ActiveCampaignNotifier>().checkCurrentCampaignIsActive();
    }
  }

  static void _checkForNewCampaigns() async {
    var authRepo = AuthRepository();
    if (await authRepo.getAccessToken() != null) {
      GetIt.I<NewCampaignNotifier>().checkNewCampaignsAvailable();
    }
  }
}

class OpenInvitationCampaignValueStore extends ChangeNotifier {
  int _openInvitationCount = 0;
  int get openInvitations => _openInvitationCount;

  void reloadOpenInvitations() async {
    try {
      var openInvitations = await GetIt.I<GrueneApiTeamsService>().getOpenInvitations();
      if (openInvitations.length != _openInvitationCount) {
        _openInvitationCount = openInvitations.length;
        notifyListeners();
      }
    } on ClientException {
      // Don't crash the app on network errors
    }
  }
}

class ActiveCampaignNotifier extends ChangeNotifier {
  bool _isCurrentCampaignActive = true;
  bool get isCurrentCampaignActive => _isCurrentCampaignActive;

  void checkCurrentCampaignIsActive() async {
    try {
      var currentCampaignId = getCurrentCampaignId();
      var isActive = false;
      if (currentCampaignId != null) {
        var allCampaigns = await GetIt.I<GrueneApiCampaignService>().findCampaigns();
        isActive = allCampaigns.any((c) => c.id == currentCampaignId && c.status == CampaignStatus.active);
      }
      _isCurrentCampaignActive = isActive;
      if (!isActive) {
        logger.d(
          'Current campaign is not active anymore. Notifying listeners to show campaign select dialog if needed.',
        );
        notifyListeners();
      }
    } on ClientException {
      // Don't crash the app on network errors
    }
  }

  void reset() {
    _isCurrentCampaignActive = true;
  }
}

class NewCampaignNotifier extends ChangeNotifier {
  bool _newCampaignsAvailable = false;
  bool get newCampaignsAvailable => _newCampaignsAvailable;

  void checkNewCampaignsAvailable() async {
    try {
      var allCampaigns = (await GetIt.I<GrueneApiCampaignService>().findCampaigns()).activeCampaigns();
      var recentlySeenCampaignIds = GetIt.I<AppSettings>().campaign.activeCampaign.recentlySeenCampaignIds ?? [];

      var newCampaigns = allCampaigns.where((c) => !recentlySeenCampaignIds.contains(c.id)).toList();
      var valueChanged = newCampaignsAvailable != newCampaigns.isNotEmpty;

      _newCampaignsAvailable = newCampaigns.isNotEmpty;
      if (valueChanged) notifyListeners();
    } on ClientException {
      // Don't crash the app on network errors
    }
  }

  void reset() {
    _newCampaignsAvailable = false;
    notifyListeners();
  }
}
