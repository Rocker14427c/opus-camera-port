#!/system/bin/sh
# OPLUS Camera Port v1.1 - SAFE version (no bootloop risk)
# These are just system properties - they CANNOT cause boot loops
MODDIR=${0%/*}

# CRITICAL: Camera2 API must be enabled
resetprop persist.camera.HAL3.enable 1
resetprop persist.vendor.camera.HAL3.enable 1

# From stock RUI4 F.23
resetprop ro.camera.hfr.enable 1
resetprop ro.camera.sound.forced 0
resetprop ro.oplus.camera.use_subsystem 1

exit 0
