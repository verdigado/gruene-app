# Guest Access Concept Prototype

> **Not for merging.** This branch visualizes a product concept. It is not feature code, has not been reviewed and
> must not end up in `main` or in a release build.

## Contents

- [Purpose](#purpose)
- [What is not real](#what-is-not-real)
- [Run the Prototype](#run-the-prototype)
- [Demo Steps](#demo-steps)
- [Static Screens](#static-screens)
- [Where to Find What](#where-to-find-what)

## Purpose

The concept: people without party membership can help with the campaign in the app for a limited time. The prototype
makes the following tangible:

- how coordinators invite, extend and block guests
- how a guest accepts the invitation and signs in
- what a guest can and cannot see in the app
- how members recognize guests in the member search, teams and leaderboards
- what happens when an access expires or is given back

The code is written to make the concept clickable, not to show how it should be built. It makes no statement about the
technical implementation.

## What is not real

The prototype is disconnected from all real data. It runs with `.env.prototype`, which sets `PROTOTYPE=true`. In that
mode:

- **No real login.** Sign-in is replaced by a locally generated, unsigned token
  (`lib/prototype/fake_auth_repository.dart`). The login host in `.env.prototype` is deliberately unreachable
  (`.invalid`).
- **No real API.** All requests to the Grüne API are answered by local sample data
  (`lib/prototype/fixture_http_client.dart`, `lib/prototype/fixtures/`). The API host in `.env.prototype` is
  deliberately unreachable as well, so a missing fixture can never fall through to a real server.
- **No push notifications.** The prototype subscribes to no push topics and registers no device.
- **No real people.** All names are made up, all e-mail addresses use `example.org`.
- **Guests are inferred.** The public API knows neither guest accounts nor invitations: `PublicProfile` has no guest
  flag and leaderboard entries have no user id. The prototype therefore recognizes guests by an id prefix or by name.
  This is a shortcut for the demo, not a proposal.
- **Hooks in existing screens.** A few app files contain small switches, all marked with `// PROTOTYPE:` and without
  effect unless `PROTOTYPE=true`.

Map tiles, address search and the connectivity check use the same public services as the app in `main`. They carry no
member or personal data.

Without `PROTOTYPE=true` the app behaves like `main`. The prototype code is still compiled in, which is one more reason
not to merge this branch.

## Run the Prototype

Prerequisites as in the [README](../README.md). The API setup described there is not needed: the prototype neither
needs nor uses an API access token.

``` shell
cp .env.prototype .env
fvm flutter pub get
fvm dart run slang
fvm dart run build_runner build
python3 tools/prototype/gen_empty_shapes.py
fvm flutter run --flavor development
```

In the app, the chip in the bottom right corner (draggable) opens the prototype menu:

- **Demo-Schritt** jumps to a prepared state (role and settings). Step 0 is the app without the concept.
- **Einstellungen** switches individual parts of the concept and variants (e.g. naming, two-factor setup) on and off.

The app is German, so the prototype menu and all screens are German as well.

## Demo Steps

| Step | Content                                              |
|------|------------------------------------------------------|
| 0    | App as today, for comparison                         |
| 1    | Coordinator invites a guest, invitation e-mail       |
| 2    | Guest accepts the invitation (optimistic two-factor) |
| 3    | Guest accepts the invitation (two-factor as today)   |
| 4    | Guest uses the app                                   |
| 5    | Members see guests                                   |
| 6    | Access about to expire, notifications                |
| 7    | Access expired                                       |

## Static Screens

`tools/prototype/guest_gallery.sh` builds a special version that walks through all states by itself and stores a
screenshot of each, sorted by flow. Requires a running Android emulator.

## Where to Find What

- `lib/prototype/flows/guest/`: screens and states of the concept
- `lib/prototype/`: prototype framework (menu, settings, roles, sample data)
- `// PROTOTYPE:` in `lib/app` and `lib/features`: the hooks in existing screens
