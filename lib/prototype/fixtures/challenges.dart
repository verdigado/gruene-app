import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/prototype.dart';

/// Challenges, chosen to show how guests and challenges collide.
///
/// Not a realistic spread of campaign work — each one is here to put a
/// specific question on screen:
///
/// - **Plakate** — a guest sits at rank 2, ahead of members. The badge in the
///   ranking is the whole "how are guests shown" question in one row.
/// - **Haustür-Woche** — ends *before* Jonas's access does. The harmless case.
/// - **Flyer-Spots** — ends 45 days out, Jonas's access in 9. He can join a
///   challenge he cannot finish, and nothing today tells him or his team.
/// - **Plakat-Sprint** — closed, with a guest in the final standings. Does a
///   past contribution survive the person's access?
/// - **Wahlkampfauftakt** — starts after Jonas's access ends. The one case the
///   app could catch up front, because both dates are known when he taps join.
///
/// The last three are the open question from the offboarding discussion, made
/// visible rather than described.

DateTime _in(int days) => DateTime.now().add(Duration(days: days));
DateTime _ago(int days) => DateTime.now().subtract(Duration(days: days));

Map<String, dynamic> _activity(String id, String type, int count) => {
  'type': type,
  'id': id,
  'count': count,
  'createdAt': _ago(40).toIso8601String(),
  'updatedAt': _ago(40).toIso8601String(),
};

Map<String, dynamic> _challenge({
  required String id,
  required String title,
  required String status,
  required DateTime start,
  required DateTime end,
  required int participants,
  required List<Map<String, dynamic>> activities,
  String? description,
}) => {
  'status': status,
  'id': id,
  'campaignId': 'campaign-1',
  'title': title,
  'description': description,
  'start': start.toIso8601String(),
  'end': end.toIso8601String(),
  'participantCount': participants,
  'activities': activities,
  'createdAt': _ago(45).toIso8601String(),
  'updatedAt': _ago(2).toIso8601String(),
};

final _posters = _challenge(
  id: 'ch-plakate',
  title: '1.000 Plakate bis zum Wahltag',
  description: 'Jedes erfasste Plakat zählt. Gemeinsames Ziel für den ganzen Kreisverband.',
  status: 'ACTIVE',
  start: _ago(21),
  end: _in(30),
  participants: 87,
  activities: [_activity('act-plakate', 'POSTER', 1000)],
);

final _doorToDoor = _challenge(
  id: 'ch-haustuer',
  title: 'Haustür-Woche Mitte',
  description: 'Eine Woche, 500 Gespräche an der Tür.',
  status: 'ACTIVE',
  start: _ago(3),
  end: _in(4),
  participants: 34,
  activities: [_activity('act-haustuer', 'HOUSE', 500)],
);

final _flyer = _challenge(
  id: 'ch-flyer',
  title: 'Flyer-Spots Pankow',
  description: 'Gute Orte für Flyer finden und eintragen.',
  status: 'ACTIVE',
  start: _ago(10),
  end: _in(45),
  participants: 19,
  activities: [_activity('act-flyer', 'FLYER_SPOT', 200)],
);

final _sprint = _challenge(
  id: 'ch-sprint',
  title: 'Plakat-Sprint August',
  description: 'Abgeschlossen — Ziel erreicht.',
  status: 'CLOSED',
  start: _ago(60),
  end: _ago(20),
  participants: 52,
  activities: [_activity('act-sprint', 'POSTER', 300)],
);

final _kickoff = _challenge(
  id: 'ch-auftakt',
  title: 'Wahlkampfauftakt Oktober',
  description: 'Startet erst — hier kann man sich schon eintragen.',
  status: 'PLANNED',
  start: _in(14),
  end: _in(60),
  participants: 6,
  activities: [_activity('act-auftakt', 'HOUSE', 400)],
);

List<Map<String, dynamic>> allChallenges() => [_posters, _doorToDoor, _flyer, _sprint, _kickoff];

Map<String, dynamic>? challengeById(String id) {
  for (final c in allChallenges()) {
    if (c['id'] == id) return c;
  }
  return null;
}

/// `GET /v1/campaigns/challenges`
Map<String, dynamic> challengeList() => {
  'data': allChallenges(),
  'total': allChallenges().length,
  'offset': 0,
  'limit': 20,
};

/// `GET /v1/campaigns/challenges/self`
///
/// A guest is in the two that matter for the offboarding question: one that
/// ends comfortably inside their access, one that outlives it.
Map<String, dynamic> ownChallenges(PrototypePersona persona) {
  final selected = persona.isGuest
      ? [(_posters, 34, 'POSTER'), (_flyer, 12, 'FLYER_SPOT')]
      : [(_posters, 61, 'POSTER'), (_doorToDoor, 18, 'HOUSE')];

  return {
    'data': [
      for (final (challenge, post, type) in selected)
        {
          ...challenge,
          'joinedAt': _ago(12).toIso8601String(),
          'participations': [
            {'type': type, 'currentContributionCount': post},
          ],
        },
    ],
    'total': selected.length,
    'offset': 0,
    'limit': 20,
  };
}

/// `GET /v1/campaigns/challenges/{id}/leaderboard`
///
/// Guests are matched by name here, because a leaderboard entry carries no
/// user id at all. Dana sits at rank 2 on the big one on purpose: the
/// interesting conversation is not "may a guest appear" but "a guest is
/// beating members, and everyone can see it".
Map<String, dynamic> challengeLeaderboard(String challengeId) {
  final entries = switch (challengeId) {
    'ch-plakate' => [
      ('Tarek Aydin', 'KV Berlin-Mitte', 78.0),
      ('Dana Weber', 'KV Berlin-Mitte', 64.0),
      ('Bea Koordination', 'KV Berlin-Mitte', 52.0),
      ('Anke Mitglied', 'KV Berlin-Mitte', 41.0),
      ('Jonas Schmitt', 'LV Berlin', 23.0),
      ('Ines Sommer', 'KV Berlin-Pankow', 11.0),
    ],
    'ch-flyer' => [
      ('Jonas Schmitt', 'LV Berlin', 31.0),
      ('Ines Sommer', 'KV Berlin-Pankow', 22.0),
      ('Dana Weber', 'KV Berlin-Mitte', 12.0),
    ],
    'ch-sprint' => [
      // Closed, with a guest in the final standings and — second row — someone
      // whose access has since ended entirely. Whether either row survives the
      // person's access is an open question of the concept.
      ('Dana Weber', 'KV Berlin-Mitte', 96.0),
      ('Erik Lang', 'KV Berlin-Pankow', 91.0),
      ('Bea Koordination', 'KV Berlin-Mitte', 88.0),
      ('Anke Mitglied', 'KV Berlin-Mitte', 55.0),
    ],
    'ch-haustuer' => [('Bea Koordination', 'KV Berlin-Mitte', 47.0), ('Anke Mitglied', 'KV Berlin-Mitte', 29.0)],
    _ => <(String, String, double)>[],
  };

  final target = (challengeById(challengeId)?['activities'] as List?)?.firstOrNull as Map<String, dynamic>?;
  final targetCount = (target?['count'] as num?)?.toDouble() ?? 100.0;

  return {
    'data': [
      for (var i = 0; i < entries.length; i++)
        {
          'rank': i + 1,
          'userName': entries[i].$1,
          'divisionName': entries[i].$2,
          'currentActivityCount': entries[i].$3,
          'activityTargetCount': targetCount,
          'activityProgressCount': entries[i].$3,
        },
    ],
    'lastUpdate': _ago(0).toIso8601String(),
    'total': entries.length,
    'offset': 0,
    'limit': 99,
  };
}

/// The guest whose access ends before a challenge they joined does — the case
/// the screens should eventually react to. Kept here so the flow code and the
/// fixtures cannot drift apart on who that is.
GuestEntry? guestWithShortAccess() {
  for (final entry in guestEntries.value) {
    if (entry.name == 'Jonas Schmitt') return entry;
  }
  return null;
}
