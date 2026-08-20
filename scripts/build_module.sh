#!/usr/bin/env bash
# Builds the flashable module ZIP from the module/ tree.
set -e

cd "$(dirname "$0")/.."

APK="module/system/priv-app/OplusCamera/OplusCamera.apk"
if [ ! -f "$APK" ]; then
    echo "ERROR: OplusCamera.apk not found at $APK"
    echo "The APK was split for GitHub's 100MB limit."
    echo "Reassemble it first:"
    echo "  cat ${APK}.part00 ${APK}.part01 > ${APK}"
    exit 1
fi

OUT="opus-camera-port-v1.1-ksu-safe.zip"
rm -f "$OUT"

(cd module && zip -qr "../$OUT" .)

echo "Built: $OUT ($(stat -c%s "$OUT") bytes)"
sha256sum "$OUT"
