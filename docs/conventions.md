# Conventions

## Contents

- [Code Style](#code-style)
- [Commits, Branches and Pull Requests](#commits-branches-and-pull-requests)
- [Translations](#translations)
- [Versioning](#versioning)

## Code Style

We follow the [Effective Dart code style](https://dart.dev/effective-dart/style).

Code should be formatted using `dart format` ([docs](https://dart.dev/tools/dart-format)).

## Commits, Branches and Pull Requests

Branch names should be written using kebab-case and have the following schema:

```
<issue_key>-your-branch-name

1234-commit-message-documentation
```

Commit messages and PR names should have the following schema:
```
<issue_key>: Your commit message

1234: Add commit message documentation
```

See [this guide](https://github.com/erlang/otp/wiki/Writing-good-commit-messages) for a general reference on how to
write good commit messages.

## Translations

Translations are managed with [slang](https://pub.dev/packages/slang). After changing a translation file, regenerate
the Dart code with `fvm dart run slang`.

### File Structure

There is one directory per language in [lib/i18n](../lib/i18n). Each file is a namespace, and each subdirectory adds
a key level:

```
lib/i18n/de/
├── common.json            t.common.*
├── campaigns.json         t.campaigns.*
├── campaigns/
│   ├── poster.json        t.campaigns.poster.*
│   └── team.json          t.campaigns.team.*
└── events.json            t.events.*
```

Add new keys to the file of the feature that uses them. If a feature's file gets too large, move a sub-section into
its own file in a subdirectory; the keys stay the same.

### Keys

- Use camelCase for keys and placeholders: `noTeamYet.hintPrivileged`, `${invitingUser}`.
- Group related keys by nesting them instead of using a common prefix: `assignedElements.hideClosed`, not
  `team_assigned_elements_hide_closed`.
- Name keys after their role in the UI:
  - `title` for headings (screen, section or dialog titles)
  - `label` for navigation/tab labels and form field labels
  - `action` for buttons and other tappable elements
  - `hint` for explanatory text
- Use `common` for texts that are shared across features (e.g. `common.actions.save`) instead of duplicating them.
- Only put text shown to users in translation files. Technical values like file name formats or identifiers belong
  in Dart code, e.g. in [constants.dart](../lib/app/constants/constants.dart).
- Remove keys that are no longer used. `fvm dart run slang analyze --full` lists candidates.

## Versioning

Versions consist of a version name and a version code and are set in [version.yaml](../version.yaml).
Versions are automatically bumped and committed using the corresponding scripts in [tools](../tools) in the
delivery [workflows](#workflows) in the CI.

### Version Name

We use the [calver schema](https://calver.org) `YYYY.MM.PATCH` for versioning.
`PATCH` is a counter for the number of releases in the corresponding month starting with 0.

Examples:

- First versions of 2024: `2024.1.0`, `2024.1.1`, `2024.1.2`.
- First version of February 2024: `2024.2.0`.

### Version Code

An additional consecutive version code is used for unique identification in the app stores.
The version code has to be incremented for every new release uploaded to the stores.
