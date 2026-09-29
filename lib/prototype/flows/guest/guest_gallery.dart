// A tooling script, not UI: every step re-reads the context from the
// navigator key right before using it, and a stale one only costs a screenshot.
// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/features/login/screens/login_screen.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/widgets/profiles_filter_dialog.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_detail.dart';
import 'package:gruene_app/prototype/flows/guest/guest_marker.dart';
import 'package:gruene_app/prototype/flows/guest/guest_notifications.dart';
import 'package:gruene_app/prototype/flows/guest/guest_own_access.dart';
import 'package:gruene_app/prototype/flows/guest/guest_person_views.dart';
import 'package:gruene_app/prototype/flows/guest/guest_screens.dart';
import 'package:gruene_app/prototype/flows/guest/guest_terms.dart';
import 'package:gruene_app/prototype/prototype.dart';
import 'package:gruene_app/prototype/settings.dart';
import 'package:gruene_app/prototype/settings_screen.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

/// Screen gallery for the guest flows: walks through every relevant state on
/// its own, so each can be screenshotted as a static screen for people who do
/// not run the prototype.
///
/// Only in a build with `--dart-define=GUEST_GALLERY=true`
/// (tools/prototype/guest_gallery.sh). Each state is announced in the log as
/// `GUEST_GALLERY|<folder>|<file>` once it has settled; the script takes the
/// screenshot and files it under that name. Deliberately timer-driven rather
/// than a two-way handshake: a release build's private files are not reachable
/// from adb, the log is.
const bool guestGalleryEnabled = bool.fromEnvironment('GUEST_GALLERY');

class _GalleryShot {
  const _GalleryShot(this.folder, this.file, this.show, {this.waitMs = 2500});

  final String folder;
  final String file;

  /// Brings the app into this state, starting from a clean navigator.
  final Future<void> Function(BuildContext context) show;

  /// How long the state needs to settle before the screenshot — longer where
  /// data loads or a map renders.
  final int waitMs;
}

Future<void> _scenario(BuildContext context, String number) async {
  final scenario = prototypeSettings.scenarios.firstWhere((s) => s.label.startsWith('$number ·'));
  prototypeSettings.apply(scenario);
  final persona = prototypePersonas.firstWhere((p) => p.id == scenario.personaId);
  applyPersona(context, persona);
  // The session restarts as the new persona; give auth and router a moment.
  await Future<void>.delayed(const Duration(milliseconds: 2500));
}

void _go(BuildContext context, String path, {Object? extra}) => GoRouter.of(context).go(path, extra: extra);

void _push(BuildContext context, Widget page) =>
    unawaited(Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)));

GuestEntry _guest(String name) =>
    guestEntries.value.firstWhere((e) => e.displayName == name || e.email.startsWith(name));

Future<PublicProfile> _profileSection(String name) async =>
    (await fetchProfiles()).firstWhere((p) => '${p.firstName} ${p.lastName}' == name);

List<_GalleryShot> _shots() {
  const k = '01_Koordination-verwaltet-Gaeste';
  const a = '02_Gast-nimmt-Einladung-an';
  const z = '03_Zwei-Faktor-Variante-wie-heute';
  const n = '04_Gast-nutzt-die-App';
  const m = '05_Mitglieder-sehen-Gaeste';
  const e = '06_Ablauf-und-Ende';
  const v = '07_Variante-Benennung-Unterstuetzende';

  return [
    // --- Coordinator (Bea, KV Mitte + Pankow) --------------------------------
    _GalleryShot(k, '01_Mitglieder-Tab_Einstieg-Gastzugaenge', (c) async {
      await _scenario(c, '1');
      _go(c, '/profiles');
    }),
    _GalleryShot(k, '02_Gastzugaenge_Uebersicht', (c) async => _push(c, const GuestAdministrationScreen())),
    _GalleryShot(k, '03_Gastzugaenge_Filter-nach-Verbaenden', (c) async {
      _push(c, const GuestAdministrationScreen());
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (c.mounted) unawaited(Future(() => showGuestFilter(c)));
    }),
    _GalleryShot(k, '04_Gastzugaenge_Aktionen-aktiver-Gast', (c) async {
      _push(c, const GuestAdministrationScreen());
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (c.mounted) showGuestActions(c, _guest('Dana Weber'));
    }),
    _GalleryShot(k, '05_Gastzugaenge_Aktionen-offene-Einladung', (c) async {
      _push(c, const GuestAdministrationScreen());
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (c.mounted) showGuestActions(c, _guest('cem.yilmaz'));
    }),
    _GalleryShot(k, '06_Gastzugaenge_Aktionen-abgelaufener-Gast', (c) async {
      _push(c, const GuestAdministrationScreen());
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (c.mounted) showGuestActions(c, _guest('Erik Lang'));
    }),
    _GalleryShot(
      k,
      '07_Gast-Detail_aktiver-Gast',
      (c) async => _push(c, GuestDetailScreen(entry: _guest('Dana Weber'))),
    ),
    _GalleryShot(
      k,
      '08_Gast-Detail_offene-Einladung',
      (c) async => _push(c, GuestDetailScreen(entry: _guest('cem.yilmaz'))),
    ),
    _GalleryShot(
      k,
      '09_Gast-Detail_abgelaufener-Gast',
      (c) async => _push(c, GuestDetailScreen(entry: _guest('Erik Lang'))),
    ),
    _GalleryShot(k, '10_Zugang-sperren_Sicherheitsabfrage', (c) async {
      _push(c, const GuestAdministrationScreen());
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (c.mounted) showBlockDialog(c, _guest('Dana Weber'));
    }),
    _GalleryShot(k, '11_Einladen_leeres-Formular', (c) async => _push(c, const GuestInviteScreen())),
    _GalleryShot(
      k,
      '12_Einladen_ausgefuellt',
      (c) async => _push(c, const GuestInviteScreen(email: 'kim.berger@example.org', division: 'KV Berlin-Mitte')),
    ),
    _GalleryShot(
      k,
      '13_Einladen_verschickt',
      (c) async =>
          _push(c, const GuestInviteScreen(email: 'kim.berger@example.org', division: 'KV Berlin-Mitte', sent: true)),
    ),

    // --- Invited person (Cem) ------------------------------------------------
    _GalleryShot(a, '01_Einladungs-Mail', (c) async {
      await _scenario(c, '2');
      if (c.mounted) _push(c, const GuestInvitationMailScreen());
    }),
    _GalleryShot(a, '02_Login_mit-Button-Einladungscode', (c) async => _push(c, const LoginScreen())),
    _GalleryShot(a, '03_Code-eingeben_leer', (c) async => _push(c, const GuestCodeEntryScreen())),
    _GalleryShot(
      a,
      '04_Code-eingeben_ungueltig',
      (c) async => _push(c, const GuestCodeEntryScreen(code: 'AB12-CD34-EF56-GH78', check: true)),
    ),
    _GalleryShot(a, '05_Willkommen', (c) async => _push(c, const GuestAcceptInvitationScreen())),
    _GalleryShot(a, '06_Angaben', (c) async => _push(c, const GuestAcceptInvitationScreen(startStep: 1))),
    _GalleryShot(a, '07_Passwort_leer', (c) async => _push(c, const GuestAcceptInvitationScreen(startStep: 2))),
    _GalleryShot(
      a,
      '08_Passwort_alle-Regeln-erfuellt',
      (c) async => _push(c, const GuestAcceptInvitationScreen(startStep: 2, examplePassword: true)),
    ),
    _GalleryShot(
      a,
      '09_Zwei-Faktor_App-registriert-sich-selbst',
      (c) async => _push(c, const GuestAcceptInvitationScreen(startStep: 3)),
    ),
    _GalleryShot(
      a,
      '10_Zwei-Faktor_eingerichtet',
      (c) async => _push(c, const GuestAcceptInvitationScreen(startStep: 3, twoFactorDone: true)),
    ),
    _GalleryShot(a, '11_Fertig', (c) async => _push(c, const GuestAcceptInvitationScreen(startStep: 4))),
    _GalleryShot(a, '12_Fehler_kein-Gastzugang-moeglich', (c) async {
      _push(c, const GuestAcceptInvitationScreen(startStep: 1));
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (c.mounted) showNoAccessDialog(c);
    }),

    // --- Two-factor as today (copy the link) ---------------------------------
    for (final (i, name) in [
      (0, '01_Uebergabe-an-Keycloak'),
      (1, '02_Keycloak-Seite_Link-kopieren'),
      (2, '03_Hinweis_zur-App-wechseln'),
      (3, '04_Link-in-der-App-einfuegen'),
    ])
      _GalleryShot(z, name, (c) async {
        if (i == 0) await _scenario(c, '3');
        if (c.mounted) _push(c, GuestAcceptInvitationScreen(startStep: 3, twoFactorSubStep: i));
      }),

    // --- Guest uses the app (Dana) -------------------------------------------
    _GalleryShot(n, '01_Artikel_gesperrt', (c) async {
      await _scenario(c, '4');
      if (c.mounted) _go(c, '/news');
    }),
    _GalleryShot(n, '02_Termine_gesperrt', (c) async => _go(c, '/events')),
    _GalleryShot(n, '03_Tools_gesperrt', (c) async => _go(c, '/tools')),
    _GalleryShot(n, '04_Wahlkampf_Karte-offen', (c) async => _go(c, '/campaigns/door'), waitMs: 6000),
    _GalleryShot(n, '05_Wahlkampf_Challenges', (c) async => _go(c, '/campaigns/challenges'), waitMs: 3500),
    _GalleryShot(n, '06_Wahlkampf_Team', (c) async => _go(c, '/campaigns/team'), waitMs: 3500),
    _GalleryShot(n, '07_Wahlkampf_Statistik', (c) async => _go(c, '/campaigns/statistics'), waitMs: 3500),
    _GalleryShot(n, '08_Mitglieder_eigenes-Profil-statt-Suche', (c) async => _go(c, '/profiles')),
    _GalleryShot(n, '09_Personen-aus-Gastsicht_reduziert', (c) async => _push(c, const GuestPersonViewsScreen())),

    // --- Members see guests (Bea) --------------------------------------------
    _GalleryShot(m, '01_Mitgliedersuche_Gast-Kennzeichnung', (c) async {
      await _scenario(c, '5');
      if (c.mounted) _go(c, '/profiles/profile-search');
    }, waitMs: 3500),
    _GalleryShot(m, '02_Mitgliedersuche_Filter-nur-Gaeste_optional', (c) async {
      guestSearchFilter.value = true;
      _go(c, '/profiles/profile-search');
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!c.mounted) return;
      unawaited(
        showFullScreenDialog<void>(
          c,
          (_) => ProfilesFilterDialog(
            // Growable on purpose: the dialog sorts the division list in place.
            divisionFilter: SelectionFilterModel(update: (_) {}, initial: null, current: null, values: <Division>[]),
            skillsFilter: SelectionFilterModel(update: (_) {}, initial: const [], current: const [], values: const []),
            interestsFilter: SelectionFilterModel(
              update: (_) {},
              initial: const [],
              current: const [],
              values: const [],
            ),
            guestFilter: SelectionFilterModel(
              update: (_) {},
              initial: GuestFilterValue.all,
              current: GuestFilterValue.onlyGuests,
              values: GuestFilterValue.values,
            ),
          ),
        ),
      );
    }),
    _GalleryShot(m, '03_Gast-Profil_verwaltbar', (c) async {
      guestSearchFilter.value = false;
      final dana = await _profileSection('Dana Weber');
      if (c.mounted) _go(c, '/profiles/${dana.id}', extra: dana);
    }, waitMs: 3000),
    _GalleryShot(m, '04_Gast-Profil_andere-Gliederung_nur-Ansicht', (c) async {
      final jonas = await _profileSection('Jonas Schmitt');
      if (c.mounted) _go(c, '/profiles/${jonas.id}', extra: jonas);
    }, waitMs: 3000),
    _GalleryShot(
      m,
      '05_Team_Statistik-mit-Gaesten-und-Ehemaligen',
      (c) async => _go(c, '/campaigns/team'),
      waitMs: 3500,
    ),
    _GalleryShot(m, '06_Challenge-Rangliste_mit-Gaesten', (c) async => _go(c, '/challenges/ch-plakate'), waitMs: 3500),
    _GalleryShot(
      m,
      '07_Challenge-Rangliste_abgeschlossen-mit-ehemaligem-Gast',
      (c) async => _go(c, '/challenges/ch-sprint'),
      waitMs: 3500,
    ),

    // --- Expiry and end (Jonas, Erik) ----------------------------------------
    _GalleryShot(e, '01_Mein-Zugang_Ablaufwarnung-14-Tage', (c) async {
      await _scenario(c, '6');
      if (c.mounted) _go(c, '/profiles');
    }),
    _GalleryShot(e, '02_Account-zurueckgeben_Sicherheitsabfrage', (c) async {
      _go(c, '/profiles');
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (c.mounted) showGiveBackAccountDialog(c);
    }),
    _GalleryShot(e, '03_Benachrichtigungen_Push-und-E-Mails', (c) async => _push(c, const GuestNotificationsScreen())),
    _GalleryShot(e, '04_Zugang-abgelaufen_statt-Login-Fehler', (c) async {
      await _scenario(c, '7');
      if (c.mounted) _go(c, '/news');
    }),

    // --- Variant: naming "Unterstützende" ------------------------------------
    _GalleryShot(v, '01_Gastzugaenge_Uebersicht', (c) async {
      await _scenario(c, '1');
      guestNaming.value = GuestNaming.supporter;
      if (c.mounted) _push(c, const GuestAdministrationScreen());
    }),
    _GalleryShot(v, '02_Mitgliedersuche_Kennzeichnung-befristet', (c) async {
      _go(c, '/profiles/profile-search');
    }, waitMs: 3500),
  ];
}

/// Runs the gallery. Started from main.dart in a GUEST_GALLERY build.
Future<void> startGuestGallery(GlobalKey<NavigatorState> navigatorKey) async {
  // Let the app boot, sign in and draw its first screen.
  await Future<void>.delayed(const Duration(seconds: 8));
  final shots = _shots();
  debugPrint('GUEST_GALLERY_START|${shots.length}');

  for (final shot in shots) {
    final context = navigatorKey.currentContext;
    if (context == null) break;
    Navigator.of(context).popUntil((route) => route.isFirst);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Print each state's first error in full, not as "Another exception".
    FlutterError.resetErrorCount();
    try {
      final c = navigatorKey.currentContext;
      if (c != null) await shot.show(c);
    } catch (error) {
      debugPrint('GUEST_GALLERY_ERROR|${shot.folder}|${shot.file}|$error');
    }
    await Future<void>.delayed(Duration(milliseconds: shot.waitMs));
    debugPrint('GUEST_GALLERY|${shot.folder}|${shot.file}');
    // Time for the screenshot before the next state replaces this one.
    await Future<void>.delayed(const Duration(milliseconds: 2200));
  }

  // Leave the app in a sensible state for whoever opens it next.
  guestNaming.value = GuestNaming.guest;
  guestSearchFilter.value = false;
  final context = navigatorKey.currentContext;
  if (context != null) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    await _scenario(context, '1');
  }
  debugPrint('GUEST_GALLERY_END');
}
