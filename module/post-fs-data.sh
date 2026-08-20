#!/system/bin/sh
# OPLUS Camera Port v1.0 - early-boot property setup
# Values extracted from stock Realme UI 4.0 (F.23) RMX3430 firmware
MODDIR=${0%/*}

# --- Camera2 / HAL3 (CRITICAL - app won't launch without these) ---
resetprop persist.camera.HAL3.enable 1
resetprop persist.vendor.camera.HAL3.enable 1
resetprop persist.camera.preview.ubwc 0
resetprop persist.vendor.camera.preview.ubwc 0
resetprop vendor.camera.hal1.packagelist OplusCamera

# --- MTK ISP pipeline (from stock F.23) ---
resetprop vendor.camera.mdp.cz.enable 1
resetprop vendor.camera.isp_nr3dc_enable 1
resetprop persist.camera.max.preview.fps 30
resetprop persist.vendor.camera.max.preview.fps 30
resetprop media.camera.ts.monotonic 1
resetprop persist.camera.dedicated.feedback 0
resetprop persist.vendor.camera.dedicated.feedback 0

# --- Stock RUI4 camera props ---
resetprop ro.camera.hfr.enable 1
resetprop ro.camera.sound.forced 0

# --- Oplus framework props ---
resetprop ro.oplus.camera.use_subsystem 1
resetprop persist.vendor.oplus.camera.support_ai_scene 1
resetprop persist.vendor.oplus.camera.support_hdr 1
resetprop persist.vendor.oplus.camera.support_beauty 1

# --- Sensor identification (RMX3430) ---
resetprop persist.vendor.camera.sensor.back 50mp_s5kjn1
resetprop persist.vendor.camera.sensor.front 8mp_gc8034
resetprop persist.vendor.camera.sensor.macro 2mp_gc02m1
resetprop persist.vendor.camera.sensor.depth 2mp_ov02b

# --- Memory management ---
resetprop persist.vendor.camera.mem.size 32
resetprop persist.vendor.camera.ion.size 16

# --- Feature flags (uncomment to try force-enable) ---
# resetprop oplus.feature.face-beauty.support true
# resetprop oplus.feature.hdr.force.auto.support true
# resetprop oplus.feature.suppernight.support true
# resetprop oplus.feature.portrait.support true

exit 0