import 'dart:convert';

import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_marker.dart';
import 'package:gruene_app/prototype/prototype.dart';

/// Bea's team, so the guest questions have somewhere to happen.
///
/// Without a team the whole Team tab is empty, and with it the invite flow,
/// the member list and the statistics — which is where a guest is either
/// visible as a guest or silently indistinguishable from a member.
///
/// The team is deliberately mixed: two members, two guests, one of them still
/// pending. The pending one matters because a guest who never accepts leaves a
/// row that looks like a member who has not answered yet.

DateTime _ago(int days) => DateTime.now().subtract(Duration(days: days));

const teamId = 'team-mitte-nord';

/// Named once so the fixtures and the flow code cannot drift apart on who is
/// in this team. The guests are the same records the coordinator administers.
Map<String, dynamic> _membership({
  required String id,
  required String userId,
  required String name,
  required String type,
  required String status,
  required int daysSince,
}) => {
  'type': type,
  'status': status,
  'id': id,
  'userId': userId,
  'userName': name,
  'invitingUserId': '10002',
  'createdAt': _ago(daysSince).toIso8601String(),
  'start': null,
  'end': null,
};

List<Map<String, dynamic>> _memberships() {
  final guests = guestEntries.value.where((e) => e.status == GuestStatus.accepted && e.name != null).toList();
  // In this concept an expired guest is treated like a former member and
  // stays in the team as a former team member.
  final former = guestEntries.value.where((e) => e.status == GuestStatus.expired && e.name != null).toList();

  return [
    _membership(
      id: 'tm-bea',
      userId: '10002',
      name: 'Bea Koordination',
      type: 'LEAD',
      status: 'ACCEPTED',
      daysSince: 40,
    ),
    _membership(
      id: 'tm-anke',
      userId: 'm-anke',
      name: 'Anke Mitglied',
      type: 'MEMBER',
      status: 'ACCEPTED',
      daysSince: 38,
    ),
    _membership(
      id: 'tm-tarek',
      userId: 'm-tarek',
      name: 'Tarek Aydin',
      type: 'MEMBER',
      status: 'ACCEPTED',
      daysSince: 21,
    ),
    for (var i = 0; i < guests.length; i++)
      _membership(
        id: 'tm-gast-$i',
        userId: guestUserId(guests[i]),
        name: guests[i].name!,
        type: 'MEMBER',
        // The second guest has not accepted yet: an invitation to someone who
        // may never arrive looks exactly like a member who has not answered.
        status: i == 0 ? 'ACCEPTED' : 'PENDING',
        daysSince: i == 0 ? 14 : 2,
      ),
    for (var i = 0; i < former.length; i++)
      _membership(
        id: 'tm-ehemalig-$i',
        userId: guestUserId(former[i]),
        name: former[i].name!,
        type: 'MEMBER',
        status: 'RESIGNED',
        daysSince: 150,
      ),
  ];
}

Map<String, dynamic> _division() => {
  'urls': <dynamic>[],
  'id': 'div-mitte',
  'divisionKey': '10000000',
  'name1': 'Kreisverband',
  'name2': 'Berlin-Mitte',
  'shortName': 'KV Berlin-Mitte',
  'hierarchy': <String, dynamic>{},
  'level': 'KV',
  'officeAddress': null,
  'emails': <dynamic>[],
};

/// `GET /v1/campaigns/teams/self`
///
/// A guest is in a team but never leads one, so for a guest persona this is
/// the same team seen from inside. Null for personas without a team, which is
/// what the "create a team" path needs in order to be reachable.
Map<String, dynamic>? ownTeam(PrototypePersona persona) {
  if (persona.id == '10001') return null; // Anke: plain member, no team yet
  return {
    'id': teamId,
    'userId': '10002',
    'division': _division(),
    'createdAt': _ago(40).toIso8601String(),
    'name': 'Haustuer Mitte Nord',
    'description': 'Haustürwahlkampf im Norden von Mitte. Gäste willkommen.',
    'memberships': _memberships(),
  };
}

/// `GET /v1/campaigns/teams/self/membershipStatistics`
///
/// Guests appear here with their numbers like everyone else. Worth looking at
/// deliberately: this is the screen where a guest's contribution is counted
/// into the team's work, and where it would go missing if an expiring access
/// took the numbers with it.
Map<String, dynamic> teamStatistics(PrototypePersona persona) {
  final team = ownTeam(persona);
  final members = (team?['memberships'] as List?) ?? const [];

  const numbers = <String, List<int>>{
    'Bea Koordination': [52, 8, 31, 12],
    'Anke Mitglied': [41, 3, 18, 9],
    'Tarek Aydin': [78, 0, 12, 4],
    'Dana Weber': [64, 11, 44, 20],
    'Jonas Schmitt': [23, 6, 9, 3],
    'Erik Lang': [37, 2, 15, 6],
  };

  return {
    'lastUpdate': DateTime.now().toIso8601String(),
    'teamStatistics': [
      for (final m in members.cast<Map<String, dynamic>>())
        {
          'status': m['status'],
          'userName': m['userName'],
          'divisionName': 'KV Berlin-Mitte',
          'memberSince': m['createdAt'],
          'posterCount': numbers[m['userName']]?[0] ?? 0,
          'flyerCount': numbers[m['userName']]?[1] ?? 0,
          'openedDoorCount': numbers[m['userName']]?[2] ?? 0,
          'closedDoorCount': numbers[m['userName']]?[3] ?? 0,
        },
    ],
  };
}

/// `GET /v1/campaigns/teams/{id}/assignments` — nothing assigned yet, but the
/// shape has to be right or the team screen throws instead of showing empty.
Map<String, dynamic> teamAssignments() => {'areas': <dynamic>[], 'routes': <dynamic>[]};

/// `POST /v1/campaigns/teams` — the team the create flow just asked for.
///
/// Echoes back what was posted rather than a canned team, so the name typed in
/// the form is the name that appears afterwards. Anything the request does not
/// carry falls back to the existing team's shape.
Map<String, dynamic> newTeam(String requestBody) {
  String? name;
  String? description;
  try {
    final sent = jsonDecode(requestBody) as Map<String, dynamic>;
    name = sent['name'] as String?;
    description = sent['description'] as String?;
  } catch (_) {
    // A body we cannot read is not worth failing the demo over.
  }

  final persona = prototypePersona.value;
  return {
    'id': 'team-neu',
    'userId': persona.id,
    'division': _division(),
    'createdAt': DateTime.now().toIso8601String(),
    'name': name ?? 'Neues Team',
    'description': description,
    'memberships': [
      _membership(
        id: 'tm-neu-lead',
        userId: persona.id,
        name: persona.name,
        type: 'LEAD',
        status: 'ACCEPTED',
        daysSince: 0,
      ),
    ],
  };
}
