---
name: release-notes
description: Write the German app store release notes for the current version and print them in the chat.
disable-model-invocation: true
---

# Release Notes

Schreib die Release Notes für die aktuelle Version. Ausgabe nur hier im Chat —
nichts committen, keine Datei anlegen.

## 1. Letzte veröffentlichte Version + Notes holen

```bash
curl -s "https://itunes.apple.com/lookup?bundleId=de.gruene.wkapp&country=de" \
  | jq -r '.results[0] | .version, "---", .releaseNotes'
```

`version` ist die letzte im App Store veröffentlichte Version und entspricht
einem Git-Tag. `releaseNotes` sind die Notes dieser Version.

## 2. Änderungen sammeln

```bash
git fetch --tags
git log --oneline <version>..HEAD
```

Nur aufnehmen, was Nutzer:innen tatsächlich merken. Weglassen: interne
Refactorings, CI, Dependabot, Version-Bumps, Test-Änderungen.

Die History mischt Squash-Merges (Titel beschreibt die Änderung) mit
Merge-Commits (Titel enthält nur den Branch-Namen). Wo der Titel nichts sagt,
schau in die enthaltenen Commits oder in den verlinkten Issue.

## 3. Format übernehmen

Format, Sprache und Tonfall aus den in Schritt 1 geholten Store-Notes
übernehmen — gleiche Struktur, gleiche Anrede, gleiche Art von Aufzählung.

## 4. Text schreiben

Ein Text für beide Stores, max. 500 Zeichen (Play-Limit; Apple erlaubt 4000).

- Klartext, kein Markdown, kein HTML
- keine spitzen Klammern
- keine Emojis
- kein ALL CAPS
- keine Werbung, keine Handlungsaufforderungen

Am Ende die Zeichenzahl mit ausgeben.
