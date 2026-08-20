#!/sbin/sh
# OPLUS Camera Port v1.1 - installer

ui_print ""
ui_print "📷 OPLUS Camera Port v1.1"
ui_print "============================"
ui_print "realme Narzo 50A (RMX3430)"
ui_print "Safe version - no bootloop risk"
ui_print ""

APK_FILE="$MODPATH/system/priv-app/OplusCamera/OplusCamera.apk"
if [ -f "$APK_FILE" ]; then
    APK_SIZE=$(stat -c%s "$APK_FILE" 2>/dev/null || echo 0)
    ui_print "📦 OplusCamera.apk: $APK_SIZE bytes"
    if [ "$APK_SIZE" -lt 100000000 ] 2>/dev/null; then
        ui_print "⚠️  APK seems too small! May not work."
    fi
else
    ui_print "❌ OplusCamera.apk MISSING!"
fi

ui_print ""
ui_print "✅ Flash complete! Reboot."
ui_print "   If camera still doesn't work, check:"
ui_print "   settings → apps → show system → OPLUS Camera"
ui_print "   → grant all permissions → clear cache"
ui_print ""
