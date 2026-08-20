# Vendor Blob Checklist

The OplusCamera APK needs the **stock MediaTek camera HAL blobs** from your
device's vendor partition. Check that these exist on your ROM.

## Quick check (run on phone with root)

```bash
# Critical MTK camera HAL
ls -la /vendor/lib64/camera* /vendor/lib64/libmtkcam_device3_hal* /vendor/lib64/libcameracustom*

# Camera configs
ls /vendor/etc/camera/ 2>/dev/null

# Camera2 API level (should say "FULL" or "LEVEL_3")
dumpsys media.camera | grep -i "level"
```

## Required files

### Camera HAL (at least one)
- `/vendor/lib64/camera.default.so`
- `/vendor/lib64/camera.mt6768.so`
- `/vendor/lib64/camera.mtk.so`

### Core MTK camera libs
- `/vendor/lib64/libmtkcam_device3_hal.so` ← **CRITICAL**
- `/vendor/lib64/libmtkcam_metadata.so`
- `/vendor/lib64/libmtkcam_pipeline.so`
- `/vendor/lib64/libmtkcam_imgbuf.so`
- `/vendor/lib64/libcameracustom.so`
- `/vendor/lib64/libcamera2ndk_vendor.so`

### Oplus libs (in vendor)
- `/vendor/lib64/liboplus.aishutter.so`
- `/vendor/lib64/liboppo_arcSoftBokehEngine_new.so`

## If blobs are missing

Your ROM likely replaced the vendor partition. On AxionOS 2.7:

1. Check if AxionOS preserves vendor: `getprop | grep vendor`
2. If vendor is AOSP generic, flash stock vendor.img:
   ```
   fastboot flash vendor vendor.img
   ```
3. Or use a ROM that keeps the stock vendor partition