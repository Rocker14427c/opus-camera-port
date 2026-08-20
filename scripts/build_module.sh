#!/usr/bin/env bash
# Builds the flashable module zip from the module/ tree.
# Reassembles the split APK parts first (GitHub 100 MB file limit).
set -e
cd "$(dirname "$0")/.."

APK="module/system/priv-app/OplusCamera/OplusCamera.apk"
if [ ! -f "$APK" ]; then
    echo "Reassembling OplusCamera.apk from parts..."
    cat "${APK}.part00" "${APK}.part01" > "$APK"
fi
if [ "$(stat -c%s "$APK")" -lt 100000000 ]; then
    echo "ERROR: assembled APK looks too small ($(stat -c%s "$APK") bytes)" >&2
    exit 1
fi

OUT="opus-camera-port-v1.0-ksu.zip"
rm -f "$OUT"
(cd module && zip -qr "../$OUT" .)
echo "Built: $OUT ($(stat -c%s "$OUT") bytes)"
sha256sum "$OUT"
