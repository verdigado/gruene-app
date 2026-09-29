#!/usr/bin/env bash
# Static screens of the guest flows, for people who do not run the prototype.
#
#   ./tools/prototype/guest_gallery.sh [target_dir]
#
# Builds the prototype with GUEST_GALLERY=true, lets it walk through every state
# on its own (lib/prototype/flows/guest/guest_gallery.dart), takes a screenshot
# whenever the app announces a settled state in the log, and files it under
# <target_dir>/<flow>/<state>.png. Afterwards the normal prototype build
# goes back onto the emulator. Needs the emulator running.
set -euo pipefail

cd "$(dirname "$0")/../.."
export ANDROID_HOME="${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}"
ADB="$ANDROID_HOME/platform-tools/adb"
PKG=de.gruene.wkapp.development
APK=build/app/outputs/flutter-apk/app-development-release.apk
TARGET="${1:-$HOME/Desktop/guest-access-screens/$(date '+%Y-%m-%d')}"

"$ADB" get-state >/dev/null 2>&1 || { echo "No emulator connected." >&2; exit 1; }

python3 tools/prototype/gen_empty_shapes.py >/dev/null

echo "Building gallery …"
flutter build apk --release --flavor development --target-platform android-arm64 \
  --dart-define=GUEST_GALLERY=true --dart-define=PROTOTYPE_BUILD="Gallery" >/dev/null
"$ADB" install -r -d "$APK" >/dev/null

rm -rf "$TARGET" && mkdir -p "$TARGET"
"$ADB" logcat -c
"$ADB" shell am force-stop "$PKG"
"$ADB" shell am start -n "$PKG/de.gruene.wkapp.MainActivity" >/dev/null

count=0
while IFS= read -r line; do
  case "$line" in
    *GUEST_GALLERY_START*)
      echo "Gallery running: ${line##*|} states" ;;
    *GUEST_GALLERY_ERROR*)
      echo "  ERROR ${line#*GUEST_GALLERY_ERROR|}" ;;
    *GUEST_GALLERY_END*)
      break ;;
    *"GUEST_GALLERY|"*)
      remainder="${line#*GUEST_GALLERY|}"
      folder="${remainder%%|*}"
      file="${remainder#*|}"
      file="${file%%[[:space:]]*}"
      mkdir -p "$TARGET/$folder"
      # </dev/null: adb would otherwise read the log stream this loop runs on
      # and swallow the lines after it, the end marker among them.
      "$ADB" exec-out screencap -p < /dev/null > "$TARGET/$folder/$file.png"
      count=$((count + 1))
      echo "  $folder/$file.png" ;;
  esac
done < <("$ADB" logcat -v raw -s flutter:I)

echo "$count screens in $TARGET"

echo "Putting the normal prototype build back on the emulator …"
flutter build apk --release --flavor development --target-platform android-arm64 \
  --dart-define=PROTOTYPE_BUILD="$(git rev-parse --short HEAD)$(git diff --quiet || echo +) · $(date '+%d.%m. %H:%M')" >/dev/null
"$ADB" install -r -d "$APK" >/dev/null
"$ADB" shell am start -n "$PKG/de.gruene.wkapp.MainActivity" >/dev/null
echo "Done."
