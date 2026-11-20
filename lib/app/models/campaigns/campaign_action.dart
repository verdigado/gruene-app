// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:gruene_app/app/services/campaign_action_database.dart';

class CampaignAction {
  int? id;
  int? poiId;
  late int poiTempId;
  CampaignActionType? actionType;
  String? serialized;

  CampaignAction({this.id, this.poiId, this.actionType, this.serialized}) {
    poiTempId = DateTime.now().millisecondsSinceEpoch;
  }

  int? get actionTypeValue {
    return actionType?.index;
  }

  set actionTypeValue(int? value) {
    if (value == null) {
      actionType = null;
    } else {
      actionType = value >= 0 && value < CampaignActionType.values.length
          ? CampaignActionType.values[value]
          : CampaignActionType.unknown;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CampaignActionFields.id: id,
      CampaignActionFields.poiId: poiId,
      CampaignActionFields.poiTempId: poiTempId,
      CampaignActionFields.actionType: actionType!.index,
      CampaignActionFields.serialized: serialized,
    };
  }

  factory CampaignAction.fromMap(Map<String, dynamic> map) {
    return CampaignAction(
      id: map[CampaignActionFields.id] as int,
      poiId: map[CampaignActionFields.poiId] != null ? map[CampaignActionFields.poiId] as int : null,
      actionType: map[CampaignActionFields.actionType] != null
          ? CampaignActionType.values[map[CampaignActionFields.actionType] as int]
          : null,
      serialized: map['serialized'] != null ? map['serialized'] as String : null,
    )..poiTempId = map[CampaignActionFields.poiTempId] as int;
  }

  String toJson() => json.encode(toMap());

  factory CampaignAction.fromJson(String source) => CampaignAction.fromMap(json.decode(source) as Map<String, dynamic>);

  CampaignAction copyWith({int? id, int? poiId, int? poiTempId, CampaignActionType? actionType, String? serialized}) {
    return CampaignAction(
      id: id ?? this.id,
      poiId: poiId ?? this.poiId,
      actionType: actionType ?? this.actionType,
      serialized: serialized ?? this.serialized,
    )..poiTempId = poiTempId ?? this.poiTempId;
  }
}

/// Stored by index in the offline queue: only append new values, never reorder or remove any
/// (checked by test/app/models/campaigns/campaign_action_test.dart).
enum CampaignActionType {
  unknown,
  addPoster,
  editPoster,
  deletePoster,
  addDoor,
  editDoor,
  deleteDoor,
  @Deprecated(
    'Flyer pins no longer exist (gruene-api#744). Kept so the stored index values stay stable; '
    'queued flyer actions are converted to door actions by the database upgrade.',
  )
  addFlyer,
  @Deprecated(
    'Flyer pins no longer exist (gruene-api#744). Kept so the stored index values stay stable; '
    'queued flyer actions are converted to door actions by the database upgrade.',
  )
  editFlyer,
  @Deprecated(
    'Flyer pins no longer exist (gruene-api#744). Kept so the stored index values stay stable; '
    'queued flyer actions are converted to door actions by the database upgrade.',
  )
  deleteFlyer,
  editRouteStatus,
  editRouteAssignment,
  editActionAreaStatus,
  editActionAreaAssignment,
}
