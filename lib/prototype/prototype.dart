import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gruene_app/app/constants/config.dart';

/// Prototype mode: runs the real app with fake auth and fixture data, so new
/// user flows can be built and demoed without Keycloak or the Gruene API.
///
/// Enabled via `PROTOTYPE=true` in `.env`. Everything in `lib/prototype/` is
/// scaffolding for design exploration and is never reached in a real build.
bool get isPrototype => Config.isPrototype;

/// Which kind of user the prototype is currently simulating.
///
/// This is the axis the guest-user flows turn on: what a person may see and do
/// before, during and after they are invited.
enum PrototypeRole {
  /// Full party member, as the app works today.
  member('Mitglied'),

  /// Non-member with limited access — the new case being prototyped.
  guest('Gast'),

  /// Member who may invite and remove guests.
  admin('Koordination');

  const PrototypeRole(this.label);
  final String label;
}

/// A simulated user, selectable at runtime from the dev drawer.
@immutable
class PrototypePersona {
  const PrototypePersona({
    required this.id,
    required this.name,
    required this.role,
    required this.divisionKey,
    this.hasPendingInvitation = false,
    this.isOnboarded = true,
    this.managedDivisions = const [],
    this.guestName,
    this.note,
  });

  final String id;
  final String name;
  final PrototypeRole role;
  final String divisionKey;

  /// Guest has been invited but has not yet accepted — entry point of the
  /// onboarding flow.
  final bool hasPendingInvitation;

  /// Guest has completed onboarding. False means they land mid-flow.
  final bool isOnboarded;

  /// The Gliederungen this persona may administer guests for.
  ///
  /// Permission is per Gliederung, not a single flag: someone can find a guest
  /// of another Gliederung in the party-wide member search and still have no
  /// right to extend or revoke them. Without this the prototype would demo the
  /// permission rule wrong in the one case it exists for.
  final List<String> managedDivisions;

  /// For guest personas: which record in `guestEntries` is *them*.
  final String? guestName;

  /// Shown in the dev drawer so it is obvious what this persona is for.
  final String? note;

  String get email => '${id.toLowerCase()}@prototype.local';

  bool get isGuest => role == PrototypeRole.guest;
  bool get canInviteGuests => role == PrototypeRole.admin;

  /// Whether this persona may act on a guest of that Gliederung — not just see
  /// them.
  bool canManage(String? division) => canInviteGuests && division != null && managedDivisions.contains(division);

  /// An unsigned but well-formed JWT.
  ///
  /// The app decodes the access token in four places (auth interceptor, token
  /// validity check, profile feature checker, push notifications). Handing them
  /// a real-shaped token keeps all of them working untouched, which is why
  /// prototype mode fakes the *token* rather than patching each consumer.
  String get fakeAccessToken {
    String segment(Map<String, dynamic> claims) =>
        base64Url.encode(utf8.encode(jsonEncode(claims))).replaceAll('=', '');

    final now = DateTime.now();
    final header = segment({'alg': 'none', 'typ': 'JWT'});
    final payload = segment({
      'sub': id,
      'uidnumber': id,
      'preferred_username': id,
      'name': name,
      'email': email,
      'division_key': divisionKey,
      'prototype_role': role.name,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(const Duration(days: 365)).millisecondsSinceEpoch ~/ 1000,
    });

    return '$header.$payload.prototype-not-a-real-signature';
  }
}

/// The personas the dev drawer offers. Add one per state a flow needs to show.
const prototypePersonas = <PrototypePersona>[
  PrototypePersona(
    id: '10001',
    name: 'Anke Mitglied',
    role: PrototypeRole.member,
    divisionKey: '10000000',
    note: 'Heutiger Stand: volles Mitglied.',
  ),
  PrototypePersona(
    id: '10002',
    name: 'Bea Koordination',
    role: PrototypeRole.admin,
    divisionKey: '10000000',
    // Deliberately not LV Berlin: Jonas is findable for her but not hers to
    // administer, which is the case the permission rule exists for.
    managedDivisions: ['KV Berlin-Mitte', 'KV Berlin-Pankow'],
    note: 'Lokale Wahlkampfkoordination — darf fuer Mitte und Pankow einladen, verlaengern, sperren.',
  ),
  PrototypePersona(
    id: '10003',
    name: 'Cem Gast (eingeladen)',
    role: PrototypeRole.guest,
    divisionKey: '10000000',
    hasPendingInvitation: true,
    isOnboarded: false,
    note: 'Einladung offen — Start des Onboardings.',
  ),
  PrototypePersona(
    id: '10004',
    name: 'Dana Gast (aktiv)',
    role: PrototypeRole.guest,
    divisionKey: '10000000',
    guestName: 'Dana Weber',
    note: 'Onboarding abgeschlossen, nutzt die App.',
  ),
  PrototypePersona(
    id: '10005',
    name: 'Jonas Gast (laeuft ab)',
    role: PrototypeRole.guest,
    divisionKey: '10000000',
    guestName: 'Jonas Schmitt',
    note: 'Zugang endet in wenigen Tagen — Ablaufwarnung und Offboarding.',
  ),
  PrototypePersona(
    id: '10006',
    name: 'Erik Gast (abgelaufen)',
    role: PrototypeRole.guest,
    divisionKey: '10000000',
    guestName: 'Erik Lang',
    note: 'Zugang bereits abgelaufen — was die Person beim Oeffnen der App sieht.',
  ),
];

/// Currently simulated persona. The dev drawer writes here; the app rebuilds.
final prototypePersona = ValueNotifier<PrototypePersona>(prototypePersonas.first);
