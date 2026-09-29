import 'package:gruene_app/prototype/fixtures/challenges.dart';
import 'package:gruene_app/prototype/fixtures/teams.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_marker.dart';
import 'package:gruene_app/prototype/prototype.dart';

/// A canned API response.
class Fixture {
  const Fixture(this.body, {this.status = 200});

  /// Null is a legitimate response — `teams/self` answers null for someone who
  /// is in no team, which is what makes the "create a team" path reachable.
  final Object? body;
  final int status;
}

/// Finds the fixture for a request, or null to fall back to an empty list.
///
/// Matching is deliberately simple — exact path first, then a prefix rule —
/// because fixtures are added on demand while building a flow, not maintained
/// as a complete mirror of the API.
Fixture? resolveFixture({
  required String method,
  required String path,
  required String requestBody,
  Map<String, String> query = const {},
}) {
  final persona = prototypePersona.value;

  // --- writes -------------------------------------------------------------
  // Accept anything the prototype posts so flows can be walked end to end.
  if (method == 'POST' || method == 'PATCH' || method == 'PUT') {
    final exact = _writeFixtures['$method $path'];
    if (exact != null) return exact;

    // Team writes answer with the team itself. The generic empty object would
    // not parse, and the screen would fail right after a successful action.
    if (path == '/v1/campaigns/teams') return Fixture(newTeam(requestBody), status: 201);
    if (RegExp(r'^/v1/campaigns/teams/[^/]+(/membership|/membershipStatus)?$').hasMatch(path)) {
      return Fixture(ownTeam(prototypePersona.value) ?? <String, dynamic>{});
    }

    return const Fixture(<String, dynamic>{}, status: 201);
  }
  if (method == 'DELETE') return const Fixture(<String, dynamic>{}, status: 200);

  // --- reads --------------------------------------------------------------
  switch (path) {
    case '/v1/users/self':
      return Fixture({
        'id': persona.id,
        'username': persona.id,
        'firstName': persona.name.split(' ').first,
        'lastName': persona.name.split(' ').skip(1).join(' '),
        'email': persona.email,
      });

    case '/v1/news':
      return Fixture({'data': _news()});

    case '/v1/profiles/self':
      return Fixture(_profile(persona));

    case '/v1/profiles':
      // The member search. Guests are in the same result set as members —
      // that is the point of the question this answers.
      return Fixture({
        'data': _searchResult(query['search']),
        'meta': {'count': 1, 'total': 1, 'offset': 0, 'limit': 100, 'hasNext': false},
      });

    case '/v1/campaigns/campaigns':
      // Needs at least one ACTIVE campaign, otherwise the app decides the
      // current campaign ended and blocks behind the select dialog.
      return Fixture({'data': _campaigns()});

    case '/v1/divisions':
      // `meta` is required and non-nullable in the generated model.
      return Fixture({
        'data': [_federalLevel()],
        'meta': {'count': 1, 'total': 1, 'offset': 0, 'limit': 20, 'hasNext': false},
      });

    case '/v1/users/self/rbac-structure':
      // Teams and challenges ask who you are before they render anything. The
      // empty shape cannot serve this one: userId is required and non-nullable.
      return Fixture({'userId': persona.id, 'groups': <dynamic>[], 'roles': <dynamic>[]});

    case '/v1/campaigns/challenges':
      return Fixture(challengeList());

    case '/v1/campaigns/challenges/self':
      return Fixture(ownChallenges(persona));

    case '/v1/campaigns/teams/self':
      return Fixture(ownTeam(persona));

    case '/v1/campaigns/statistics':
      // The Statistik tab. Each type needs all its levels, or the screen
      // stays on its spinner.
      return Fixture(_campaignStatistics());

    case '/v1/campaigns/teams/statistics':
      // Team rankings in the Statistik tab. Empty is enough — the lists are
      // optional, only the three categories are required.
      return Fixture({'poster': <String, dynamic>{}, 'flyer': <String, dynamic>{}, 'house': <String, dynamic>{}});

    case '/v1/campaigns/teams/self/membershipStatistics':
      return Fixture(teamStatistics(persona));

    case '/v1/campaigns/teams/pendingInvitations':
      // Drives the guest onboarding entry point.
      return Fixture(persona.hasPendingInvitation ? _pendingInvitation(persona) : const <dynamic>[]);
  }

  // Templated challenge paths, which the exact-match switch above cannot take.
  final leaderboard = RegExp(r'^/v1/campaigns/challenges/([^/]+)/leaderboard$').firstMatch(path);
  if (leaderboard != null) return Fixture(challengeLeaderboard(leaderboard.group(1)!));

  if (RegExp(r'^/v1/campaigns/teams/[^/]+/assignments$').hasMatch(path)) {
    return Fixture(teamAssignments());
  }

  // The challenge detail loads the campaign its challenge belongs to.
  if (RegExp(r'^/v1/campaigns/campaigns/[^/]+$').hasMatch(path)) return Fixture(_campaigns().first);

  final single = RegExp(r'^/v1/campaigns/challenges/([^/]+)$').firstMatch(path);
  if (single != null) {
    final challenge = challengeById(single.group(1)!);
    if (challenge != null) return Fixture(challenge);
  }

  return _readFixtures[path];
}

/// Bundesverband. Required: `NewsScreenContainer` calls `divisions().bundesverband()`,
/// which is an unguarded `firstWhere` on divisionKey '10000000'.
Map<String, dynamic> _federalLevel() => {
  'urls': <dynamic>[],
  'id': '1',
  'divisionKey': '10000000',
  'name1': 'Bundesverband',
  'name2': 'Deutschland',
  'shortName': 'BV',
  'hierarchy': <String, dynamic>{},
  'level': 'BV',
  'officeAddress': null,
  'emails': <dynamic>[],
};

List<Map<String, dynamic>> _news() => [
  {
    'id': 'news-1',
    'title': 'Haustuerwahlkampf startet im Bezirk Mitte',
    'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    'division': _federalLevel(),
    'categories': <dynamic>[],
    'summary': 'Ab Samstag sind wir wieder an den Tueren unterwegs. Alle Infos zur Anmeldung.',
    'featuredImage': null,
    'body': {'type': 'html', 'content': '<p>Details folgen in Kuerze.</p>'},
    'bookmark': null,
  },
  {
    'id': 'news-2',
    'title': 'Neu: Gaeste koennen mitmachen',
    'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    'division': _federalLevel(),
    'categories': <dynamic>[],
    'summary': 'Nicht-Mitglieder koennen ab sofort eingeladen werden und im Wahlkampf helfen.',
    'featuredImage': null,
    'body': {'type': 'html', 'content': '<p>Details folgen in Kuerze.</p>'},
    'bookmark': null,
  },
];

Map<String, dynamic> _profile(PrototypePersona persona) {
  final parts = persona.name.split(' ');
  return {
    'id': 'profile-${persona.id}',
    'userId': persona.id,
    'personalId': persona.id,
    'username': persona.id,
    'firstName': parts.first,
    'lastName': parts.skip(1).join(' '),
    'email': persona.email,
    'phoneNumbers': <dynamic>[],
    'messengers': <dynamic>[],
    'socialMedia': <dynamic>[],
    'tags': <dynamic>[],
    'roles': <dynamic>[],
    'achievements': <dynamic>[],
    'privacy': {'overall': 'BV_WIDE', 'email': 'PRIVATE'},
  };
}

/// The member search result set: members and guests together.
///
/// Guests are built from the same records the coordinator screens work on, so
/// extending a guest in Gastzugänge changes what the search shows.
List<Map<String, dynamic>> _searchResult(String? search) {
  final all = [
    ..._members,
    for (final entry in guestEntries.value)
      if (entry.status == GuestStatus.accepted && entry.name != null)
        _publicProfile(
          userId: guestUserId(entry),
          name: entry.name!,
          division: entry.division,
          // A guest has no Personen-Nr. — there is no membership to number.
          personalId: '',
        ),
  ];

  final term = search?.trim().toLowerCase() ?? '';
  if (term.isEmpty) return all;
  return all.where((p) => '${p['firstName']} ${p['lastName']}'.toLowerCase().contains(term)).toList();
}

final _members = [
  _publicProfile(userId: 'm-bea', name: 'Bea Koordination', division: 'KV Berlin-Mitte'),
  _publicProfile(userId: 'm-anke', name: 'Anke Mitglied', division: 'KV Berlin-Mitte'),
  _publicProfile(userId: 'm-frank', name: 'Frank Landesbuero', division: 'LV Berlin'),
  _publicProfile(userId: 'm-ines', name: 'Ines Sommer', division: 'KV Berlin-Pankow'),
  _publicProfile(userId: 'm-tarek', name: 'Tarek Aydin', division: 'KV Berlin-Mitte'),
];

Map<String, dynamic> _publicProfile({
  required String userId,
  required String name,
  required String division,
  String? personalId,
}) {
  final parts = name.split(' ');
  return {
    'id': 'profile-$userId',
    'userId': userId,
    'personalId': personalId ?? userId,
    'username': userId,
    'firstName': parts.first,
    'lastName': parts.skip(1).join(' '),
    'phoneNumbers': <dynamic>[],
    'messengers': <dynamic>[],
    'socialMedia': <dynamic>[],
    'tags': <dynamic>[],
    'roles': <dynamic>[],
    'achievements': <dynamic>[],
    // For a guest this is the Gliederung that invited them, not a membership.
    // The API has no way to say which of the two it is — a member and a guest
    // come back as the same shape.
    'memberships': [
      {
        'division': _division(division),
        'joinedAt': DateTime.now().subtract(const Duration(days: 400)).toIso8601String(),
      },
    ],
  };
}

/// Takes "KV Berlin-Mitte" apart the way the app puts it back together:
/// `shortDisplayName` is `level` plus `name2`, so the level has to live in the
/// field and not in the string, or every row just reads "KV".
Map<String, dynamic> _division(String naming) {
  final parts = naming.split(' ');
  final level = parts.first;
  final place = parts.skip(1).join(' ');
  return {
    'urls': <dynamic>[],
    'id': 'div-${naming.hashCode}',
    'divisionKey': '10000000',
    'name1': level == 'KV' ? 'Kreisverband' : 'Landesverband',
    'name2': place,
    'shortName': naming,
    'hierarchy': <String, dynamic>{},
    'level': level,
    'officeAddress': null,
    'emails': <dynamic>[],
  };
}

List<Map<String, dynamic>> _campaigns() => [
  {
    'id': 'campaign-1',
    'name': 'Bundestagswahl 2026',
    'description': 'Laufende Kampagne fuer den Prototyp.',
    'scope': 'FEDERAL',
    'type': 'ELECTION',
    'status': 'ACTIVE',
    'divisionKey': '10000000',
    'start': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    'end': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
    'electionDate': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
  },
];

Map<String, dynamic> _campaignStatistics() {
  Map<String, dynamic> counts(double own, double division, double state, double germany) => {
    'own': own,
    'subDivision': null,
    'division': division,
    'state': state,
    'germany': germany,
    'byStatus': <dynamic>[],
  };
  return {
    'poster': counts(42, 1280, 15400, 212000),
    'flyer': counts(310, 9800, 118000, 1650000),
    'house': counts(87, 2400, 31000, 486000),
  };
}

List<Map<String, dynamic>> _pendingInvitation(PrototypePersona persona) => [
  {
    'membershipId': 'membership-1',
    'teamId': 'team-1',
    'invitingUser': 'Bea Vorstand',
    'invitationDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    'teamName': 'Haustuerwahlkampf Mitte',
    'teamDescription': 'Tuer-zu-Tuer im Bezirk Mitte.',
    'teamDivision': _federalLevel(),
    'type': 'MEMBER',
  },
];

/// Add read fixtures here as screens need them.
const _readFixtures = <String, Fixture>{};

/// Add write responses here when a flow needs a specific reply.
const _writeFixtures = <String, Fixture>{};
