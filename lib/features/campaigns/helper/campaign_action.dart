// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:gruene_app/app/services/campaign_action_database.dart';

class CampaignAction {
  int? id;
  int? poiId;
  late int poiTempId;
  CampaignActionType? actionType;
  String? serialized;

  CampaignAction({
    this.id,
    this.poiId,
    this.actionType,
    this.serialized,
  }) {
    poiTempId = DateTime.now().millisecondsSinceEpoch;
  }

  int? get actionTypeValue {
    _ensureStableEnumValues();
    return actionType?.index;
  }

  set actionTypeValue(int? value) {
    _ensureStableEnumValues();
    if (value == null) {
      actionType = null;
    } else {
      actionType = value >= 0 && value < CampaignActionType.values.length
          ? CampaignActionType.values[value]
          : CampaignActionType.unknown;
    }
  }

  void _ensureStableEnumValues() {
    assert(CampaignActionType.unknown.index == 0);
    assert(CampaignActionType.addPoster.index == 1);
    assert(CampaignActionType.editPoster.index == 2);
    assert(CampaignActionType.deletePoster.index == 3);
    assert(CampaignActionType.addDoor.index == 4);
    assert(CampaignActionType.editDoor.index == 5);
    assert(CampaignActionType.deleteDoor.index == 6);
    assert(CampaignActionType.addFlyer.index == 7);
    assert(CampaignActionType.editFlyer.index == 8);
    assert(CampaignActionType.deleteFlyer.index == 9);
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

  CampaignAction copyWith({
    int? id,
    int? poiId,
    int? poiTempId,
    CampaignActionType? actionType,
    String? serialized,
  }) {
    return CampaignAction(
      id: id ?? this.id,
      poiId: poiId ?? this.poiId,
      actionType: actionType ?? this.actionType,
      serialized: serialized ?? this.serialized,
    )..poiTempId = poiTempId ?? this.poiTempId;
  }
}

enum CampaignActionType {
  unknown,
  addPoster,
  editPoster,
  deletePoster,
  addDoor,
  editDoor,
  deleteDoor,
  addFlyer,
  editFlyer,
  deleteFlyer,
}
