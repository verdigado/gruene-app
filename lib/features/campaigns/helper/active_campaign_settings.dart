// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:json_annotation/json_annotation.dart';

part 'active_campaign_settings.g.dart';

@JsonSerializable()
class ActiveCampaignSettings extends ChangeNotifier {
  String? _recentSelectedCampaignId;
  String? get recentSelectedCampaignId => _recentSelectedCampaignId;

  set recentSelectedCampaignId(String? recentSelectedCampaignId) {
    _recentSelectedCampaignId = recentSelectedCampaignId;
    save();
    notifyListeners();
  }

  ActiveCampaignSettings({String? recentSelectedCampaignId}) : _recentSelectedCampaignId = recentSelectedCampaignId;

  static Future<ActiveCampaignSettings> restore() async {
    var secureStorage = GetIt.I<FlutterSecureStorage>();
    var activeCampaignsSerialized = await secureStorage.read(key: SecureStorageKeys.activeCampaigns);
    if (activeCampaignsSerialized == null) {
      return ActiveCampaignSettings();
    }
    var data = jsonDecode(activeCampaignsSerialized) as Map<String, dynamic>;

    return ActiveCampaignSettings.fromJson(data);
  }

  void save() {
    var secureStorage = GetIt.I<FlutterSecureStorage>();
    secureStorage.write(key: SecureStorageKeys.activeCampaigns, value: jsonEncode(toJson()));
  }

  factory ActiveCampaignSettings.fromJson(Map<String, dynamic> json) => _$ActiveCampaignSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveCampaignSettingsToJson(this);
}
