# opus-camera-port

**Port of the realme Narzo 50A (RMX3430) stock camera — `OplusCamera` 3.116.1 from Realme UI 4.0 / ColorOS 13.0.1 (Android 13, build F.23) — for AOSP-based custom ROMs.**

Test target: **AxionOS 2.7 (Android 16)** with **KernelSU**. Should also work on other A13+ AOSP ROMs for the Narzo 50A (LineageOS, crDroid, etc.) with KernelSU or Magisk.

---

## What this port includes

| Component | Stock location | Installed to |
|---|---|---|
| `OplusCamera.apk` (com.oplus.camera, v3.116.1) — manifest patched, test-platform-key signed | `my_product/non_overlay/app/OplusCamera/` | `/system/priv-app/OplusCamera/` |
| `oplus-framework.jar` — OPlus framework classes (shared library) | `system/framework/` | `/system/framework/` |
| `oplus-support-wrapper.jar` — hidden-API wrapper classes (shared library) | `system/framework/` | `/system/framework/` |
| `oplus-framework-res.apk` — framework resources (package `oplus`) | `system_ext/framework/` | `/system/priv-app/oplus-framework-res/` + `/system/framework/` |
| `com.oplus.camera.unit.sdk.jar` + adapter — camera unit SDK | `my_product/product_overlay/framework/` | `/system/framework/` |
| 21 camera feature native libs (beauty, blur, bokeh, doc scan, APU client…) | `my_product/lib{,64}/` | `/system/lib{,64}/` |
| `CameraExtensionsProxy.apk` (com.android.cameraextensions) | `system/app/` | `/system/app/` |
| Camera permission/default-grant/hidden-API-whitelist XMLs | various | `/system/etc/…` |
| `engineer_camera_config` | `my_product/etc/camera/` | `/system/etc/camera/` |
| Camera props (`ro.camera.hfr.enable`, `ro.camera.sound.forced`) | stock build.prop | set via `post-fs-data.sh` / `system.prop` |

## Why the APK was modified

The stock camera on Realme UI runs against the OPlus framework that lives on the **boot classpath**, which AOSP ROMs don't have. Three surgical changes were made to make it run on AOSP:

1. **Added `<uses-library>` declarations** (`com.oplus.framework`, `com.oplus.support-wrapper`, `com.oplus.camera.unit.sdk`) so the framework classes shipped by this module are visible to the app through AOSP's shared-library mechanism.
2. **Removed `android:testOnly="true"`.**
3. **Re-signed with the AOSP test platform key** (public key). On ROMs signed with **test keys** (almost all unofficial builds, incl. unofficial AxionOS) the app is then platform-signed and receives its privileged permissions (`SYSTEM_CAMERA`, etc.) via the bundled `privapp-permissions` XML.

The framework-res APK additionally had its `android.uid.system` shared UID neutralized (a plain package can't join the system UID on AOSP).

> **On a ROM signed with private keys** (official builds): install still works, but privileged permissions won't be granted. Camera + video still work (regular `CAMERA` permission is auto-granted); lock-screen quick launch and a few signature-protected extras won't. Fix: re-sign `OplusCamera.apk` with the ROM's platform key.

## Install

1. Make sure your ROM has a **working camera** with some other app (Aperture/GCam) — this module only adds the stock app, it does not touch the camera HAL.
2. Download `opus-camera-port-v1.0-ksu.zip` from **Releases**.
3. Install it in **KernelSU** (or Magisk) → Modules → Install from storage.
4. Reboot. First boot takes a bit longer (dexopt of the big APK).
5. Open **Camera**. Grant permissions if asked (they're normally auto-granted).

### Uninstall
Remove the module in the KernelSU/Magisk app and reboot.

## Known issues / reality check

This is a **best-effort port**. The stock app expects ColorOS services, MediaTek vendor tags and framework hooks that an AOSP ROM doesn't have, so:

- ✅ Expected to work: photo, video, HDR (basic), zoom, flash, gallery integration, filters.
- ⚠️ May work: 50MP full-res, portrait/bokeh (libs included), night mode, beauty — depends on how much the ROM's HAL exposes.
- ❌ Likely broken: AI scene detection (needs MTK APU vendor services), watermark/slogan, some ColorOS cloud features.

## Troubleshooting

If the camera force-closes, grab a log and open an issue:

```sh
# clear old logs, reproduce the crash, then:
adb logcat -d | grep -iE "oplus|camera" > camera_log.txt
# or with root on-device (Termux/termux-su):
su -c "logcat -d" | grep -iE "oplus|camera" > /sdcard/camera_log.txt
```

Common issues and fixes:

| Symptom | Likely cause | Fix |
|---|---|---|
| App doesn't appear after boot | ROM signed with private keys → priv-app rejected | Check `adb shell pm list packages \| grep oplus`; try re-signing with ROM platform key |
| `Can't connect to camera` | Camera HAL busy / not compatible | Make sure no other camera app is holding the camera; try `adb shell killall cameraserver` |
| Crash with `NoClassDefFoundError: com.oplus.*` | Shared library not loaded | Make sure module mounted (`adb shell ls /system/framework/oplus-framework.jar`); try wiping dalvik (`su -c "rm -rf /data/dalvik-cache"`) |
| `hiddenapi` denial spam | Whitelist not applied on your ROM | Use LSPosed + "HiddenApiBypass"/`liboemcrypto`-style framework patch, or `adb shell settings put global hidden_api_policy 1` |
| SELinux denials for the app | ROM enforcing policy | `adb shell dmesg \| grep -i avc \| grep camera` — if denials, boot with `adb shell setenforce 0` (temporarily) and report |

## Repo layout

```
module/                 → the KernelSU/Magisk module tree (source of the zip)
  system/…
scripts/build_module.sh → reassembles the split APK parts and builds the zip
docs/NOTES.md           → technical porting notes (super.img layout, EROFS, patches applied)
```

`module/system/priv-app/OplusCamera/OplusCamera.apk` is stored **split** (`*.part00`, `*.part01`) because GitHub limits files to 100 MB. The release zip is fully assembled.

## Credits / sources

- Camera, framework and libs: realme Narzo 50A RUI4 F.23 firmware (`Realme-Narzo-50a-Rui4-firmware`)
- Re-signed with AOSP test keys (`build/target/product/security`)
- Same concept as the community [OPlus Core](https://github.com/reiryuki/OPlus-Core-Magisk-Module) module for OPlus app ports

## License

The extracted binaries are proprietary realme/OPLUS (MediaTek) software — for personal use on your own device. The scripts/XML here are MIT.
