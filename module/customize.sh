#!/sbin/sh
# OPLUS Camera Port - customize.sh for KernelSU/Magisk
ui_print ""
ui_print "📷 OPLUS Camera Port v1.0"
ui_print "===================================="
ui_print "realme Narzo 50A (RMX3430)"
ui_print "Stock RUI4 Camera for AOSP ROMs"
ui_print ""

# Architecture check
ARCH=$(getprop ro.product.cpu.abi)
ui_print "Architecture: $ARCH"
[ "$ARCH" != "arm64-v8a" ] && ui_print "⚠️ Warning: Expected arm64-v8a"

# Check for the APK (reassembled or not)
APK_FILE="$MODPATH/system/priv-app/OplusCamera/OplusCamera.apk"
if [ ! -f "$APK_FILE" ]; then
    ui_print "⚠️ OplusCamera.apk not found!"
    ui_print "   Run: cat OplusCamera.apk.part0* > OplusCamera.apk"
    ui_print "   Then re-zip and flash"
fi

ui_print ""
ui_print "✅ Flash complete! Reboot to apply."
ui_print "   If camera crashes, check vendor blobs:"
ui_print "   https://github.com/Rocker14427c/opus-camera-port#readme"
ui_print ""