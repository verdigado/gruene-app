import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_flow.dart';
import 'package:gruene_app/prototype/settings.dart';

/// Everything the prototype can show, in one place.
///
/// This is the list to extend when a new flow starts: define the experiment
/// next to its screens in `lib/prototype/flows/<name>/`, add it here, and it
/// appears in the settings view and the dev drawer by itself.
void registerPrototypeExperiments() {
  prototypeSettings.register(
    experiments: [guestFlow],
    // Numbered in the order the concept is best walked through. Each one resets
    // everything else, so a step always starts from the same state no matter
    // what the previous one left behind.
    scenarios: [
      const PrototypeScenario(
        label: '0 · Stand heute',
        description: 'Nichts aktiv — die App, wie sie heute ausgeliefert wird. Der Vergleichspunkt.',
        personaId: '10001',
      ),
      PrototypeScenario(
        label: '1 · Koordination lädt ein',
        description: 'Bea: Gastzugänge im Mitglieder-Tab, Einladung verschicken, die Einladungs-Mail.',
        personaId: '10002',
        experiments: [guestFlow],
        screens: [guestScreenAdministration, guestScreenMail],
      ),
      PrototypeScenario(
        label: '2 · Gast nimmt an',
        description: 'Cem: Code eingeben, Angaben, Passwort, Zwei-Faktor in der optimistischen Variante.',
        personaId: '10003',
        experiments: [guestFlow],
        configure: () => twoFactorVariant.value = TwoFactorVariant.optimistic,
        screens: [guestScreenMail, guestScreenLogin, guestScreenCode, guestScreenAccept],
      ),
      PrototypeScenario(
        label: '3 · Gast nimmt an — Zwei-Faktor heute',
        description: 'Derselbe Weg mit dem Keycloak-Umweg: Link kopieren und einfügen.',
        personaId: '10003',
        experiments: [guestFlow],
        configure: () => twoFactorVariant.value = TwoFactorVariant.realistic,
        screens: [guestScreenAccept],
      ),
      PrototypeScenario(
        label: '4 · Gast nutzt die App',
        description: 'Dana: Wahlkampf offen, News/Termine/Tools mit Teaser, Mitglieder-Tab als eigenes Profil.',
        personaId: '10004',
        experiments: [guestFlow],
        screens: [guestScreenPeople],
      ),
      PrototypeScenario(
        label: '5 · Mitglieder sehen Gäste',
        description: 'Bea: Gast-Badge in Suche, Team und Rangliste; Jonas (LV Berlin) nur zur Ansicht.',
        personaId: '10002',
        experiments: [guestFlow],
      ),
      PrototypeScenario(
        label: '6 · Zugang läuft aus',
        description: 'Jonas: Ablaufwarnung, Benachrichtigungen, Account zurückgeben.',
        personaId: '10005',
        experiments: [guestFlow],
        screens: [guestScreenNotifications],
      ),
      PrototypeScenario(
        label: '7 · Zugang abgelaufen',
        description: 'Erik: was jemand sieht, dessen Zugang vorbei ist.',
        personaId: '10006',
        experiments: [guestFlow],
      ),
    ],
  );
}
