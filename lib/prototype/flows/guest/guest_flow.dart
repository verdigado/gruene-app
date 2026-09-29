import 'package:gruene_app/features/login/screens/login_screen.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_expired.dart';
import 'package:gruene_app/prototype/flows/guest/guest_marker.dart';
import 'package:gruene_app/prototype/flows/guest/guest_membership.dart';
import 'package:gruene_app/prototype/flows/guest/guest_notifications.dart';
import 'package:gruene_app/prototype/flows/guest/guest_own_access.dart';
import 'package:gruene_app/prototype/flows/guest/guest_person_views.dart';
import 'package:gruene_app/prototype/flows/guest/guest_screens.dart';
import 'package:gruene_app/prototype/flows/guest/guest_terms.dart';
import 'package:gruene_app/prototype/settings.dart';

/// Gastzugänge — non-members working in the app on a temporary invitation.
/// A concept, see docs/guest-access-concept.md.
///
/// The three sub-toggles are the three places the flow reaches into the real
/// app. Each can be shown on its own, so the locked sections, the
/// administration screen and the code login can be discussed separately.

/// Guests see a teaser instead of the sections they may not use.
final guestLockedSections = PrototypeToggle(
  id: 'guest.locked_sections',
  label: 'Gesperrte Bereiche',
  description:
      'News, Termine und Tools zeigen Gästen einen Teaser; Mitglieder zeigt ihr eigenes Profil statt der Suche.',
  defaultOn: true,
);

/// Guest administration in the member's own profile.
final guestAdministration = PrototypeToggle(
  id: 'guest.administration',
  label: 'Gastzugänge verwalten',
  description: 'Einstieg "Gastzugänge" im eigenen Profil — nur für Koordination.',
  defaultOn: true,
);

/// Entry point for an invited guest on the login screen.
final guestCodeLogin = PrototypeToggle(
  id: 'guest.code_login',
  label: 'Einladungscode im Login',
  description: 'Zusätzlicher Einstieg "Einladungscode eingeben" auf dem Login-Screen.',
  defaultOn: true,
);

/// The end of a guest's time: warning, expiry, and leaving voluntarily.
final guestOffboarding = PrototypeToggle(
  id: 'guest.offboarding',
  label: 'Offboarding',
  description: 'Ablaufwarnung, Abgelaufen-Screen statt Login-Fehler, Account zurückgeben, Benachrichtigungen.',
  defaultOn: true,
);

final guestFlow = PrototypeExperiment(
  id: 'guest',
  label: 'Gastzugänge',
  description: 'Nicht-Mitglieder arbeiten befristet in der App mit — Einladung, Onboarding, Verwaltung.',
  settings: [
    // First, because it changes every other label on this list.
    guestNaming,
    guestLockedSections,
    guestAdministration,
    guestCodeLogin,
    guestLabeling,
    guestSearchFilter,
    guestOffboarding,
    guestMembership,
    twoFactorVariant,
  ],
  // The complete catalogue, as the settings list it. The menu offers only the
  // ones the active demo step needs (experiments.dart).
  screens: [
    guestScreenAdministration,
    guestScreenInvite,
    guestScreenMail,
    guestScreenCode,
    guestScreenAccept,
    guestScreenLogin,
    guestScreenOwnAccess,
    guestScreenPeople,
    guestScreenExpired,
    guestScreenNotifications,
    guestScreenApplication,
  ],
);

final guestScreenAdministration = PrototypeScreen('Gastzugänge', (_) => const GuestAdministrationScreen());
final guestScreenInvite = PrototypeScreen('Einladen', (_) => const GuestInviteScreen());
final guestScreenMail = PrototypeScreen('Einladungs-Mail', (_) => const GuestInvitationMailScreen());
final guestScreenCode = PrototypeScreen('Code eingeben', (_) => const GuestCodeEntryScreen());
final guestScreenAccept = PrototypeScreen('Einladung annehmen', (_) => const GuestAcceptInvitationScreen());

// The real login screen, where the code button lives. Pushed rather than
// reached by logging out: the logout path runs through a loading overlay, and
// the navigator context sits above the Overlay, so it throws.
final guestScreenLogin = PrototypeScreen('Login-Screen', (_) => const LoginScreen());

final guestScreenOwnAccess = PrototypeScreen('Mein Zugang (Gast)', (_) => const GuestOwnAccessScreen());
final guestScreenPeople = PrototypeScreen('Personen als Gast', (_) => const GuestPersonViewsScreen());
final guestScreenExpired = PrototypeScreen('Zugang abgelaufen', (_) => const GuestExpiredScreen());
final guestScreenNotifications = PrototypeScreen('Benachrichtigungen', (_) => const GuestNotificationsScreen());
final guestScreenApplication = PrototypeScreen(
  'Antrag gestellt (Variante)',
  (_) => const GuestApplicationSubmittedScreen(),
);
