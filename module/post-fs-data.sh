#!/system/bin/sh
# OPLUS Camera Port - early-boot property setup
# Values taken from stock Realme UI 4.0 (F.23) firmware for RMX3430 (Narzo 50A).
MODDIR=${0%/*}

# Camera feature props the stock app reads at runtime
resetprop ro.camera.hfr.enable 1
resetprop ro.camera.sound.forced 0

# Optional feature flags (uncomment to force-enable; some features may crash
# on AOSP camera HALs if the underlying hardware/vendor-tag support is missing).
# resetprop oplus.feature.face-beauty.support true
# resetprop oplus.feature.hdr.force.auto.support true
# resetprop oplus.feature.suppernight.support true
# resetprop oplus.feature.portrait.support true

exit 0
