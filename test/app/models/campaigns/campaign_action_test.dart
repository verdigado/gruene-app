import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/campaign_action.dart';

void main() {
  test('CampaignActionType keeps the index of every value', () {
    // Queued actions are stored by index on the devices. A value may only be appended at the end;
    // reordering or removing one would change the meaning of actions already queued.
    expect(CampaignActionType.values.map((type) => type.name).toList(), [
      'unknown',
      'addPoster',
      'editPoster',
      'deletePoster',
      'addDoor',
      'editDoor',
      'deleteDoor',
      'addFlyer',
      'editFlyer',
      'deleteFlyer',
      'editRouteStatus',
      'editRouteAssignment',
      'editActionAreaStatus',
      'editActionAreaAssignment',
    ]);
  });
}
