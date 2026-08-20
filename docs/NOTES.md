# Technical notes — Narzo 50A RUI4 camera port

Target: realme Narzo 50A (RMX3430, MT6769/Helio G85), stock build `F.23`
(Realme UI 4.0 = ColorOS 13.0.1, Android 13, security patch 2024-06-05).
Source: `Rocker14427c/Realme-Narzo-50a-Rui4-firmware` (super.part00–05, v1.0-F.23 release).

## 1. super.img layout (how it was unpacked)

The super image (10,200,547,328 bytes) is **not** the plain AOSP layout:

| Offset | Content |
|---|---|
| 0x0000–0x0FFF | zeros |
| 0x1000 | `LpMetadataGeometry` (magic `0x616C4467` "gDla", size 52, meta_max 65536, 3 slots, block 4096) |
| 0x2000 | backup geometry |
| 0x3000, 0x13000, 0x23000, 0x33000, 0x43000, 0x53000 | 5×64 KB metadata slots (`0PLA` header, v10.0, 128-byte header, serialized table descriptors `{num, entry_size, next_table_offset}`) |
| 0x100000 (1 MB) | **data region start** — partition images, 1 MB aligned |

Partition → extent: `physical = 0x100000 + (target_data − first_logical_sector) × 512`
(first_logical_sector = 2048). Every partition image is a **raw EROFS filesystem**
(superblock magic `e2 e1 f5 e0` at +1024; `OPLUS_USE_EROFS=true` in the build env),
**not** sparse — hence the partitions are not extractable with `simg2img`.

Useful: `scripts/unpack_super.py` (in the firmware repo lineage) — parse with a
modified liblp reader, mount with `erofsfuse` / `dump.erofs`.

## 2. Where the camera lives in stock

- `my_product/non_overlay/app/OplusCamera/OplusCamera.apk` — the camera (com.oplus.camera, 122.6 MB)
- `system/framework/oplus-framework.jar` (5.7 MB dex) + `oplus-support-wrapper.jar` — boot-classpath libs
- `system_ext/framework/oplus-framework-res.apk` — resource-only package `oplus`, sharedUserId `android.uid.system`
- `my_product/product_overlay/framework/com.oplus.camera.unit.sdk{,.adapter}.jar`
- `my_product/lib{,64}/*.so` — feature libs (beauty/blur/bokeh/doc-scan/APU)
- `my_product/etc/camera/engineer_camera_config`
- `my_product/product_overlay/etc/permissions/oplus_camera_default_grant_permissions_list.xml`
- `system/etc/sysconfig/hiddenapi-package-whitelist.xml` contains `com.oplus.camera`

## 3. APK analysis results (why the patches)

- Manifest: package `com.oplus.camera`, minSdk 30 / targetSdk 31, `testOnly=true`,
  no `uses-library` for the OPlus framework (stock gets it from bootclasspath).
- Dex references 1600+ `com.oplus.camera.*` classes and ~90 external `com.oplus.*`
  packages: `com.oplus.compat.*`, `com.oplus.os.OplusBuild`,
  `com.oplus.content.OplusFeatureConfigManager`, `com.oplus.anim.EffectiveAnimationView`,
  `com.oplus.orms`, `com.oplus.epona`, `com.oplus.inner.*`, `com.oplus.util.OplusFontUtils`, …
  — all resolved by shipping `oplus-framework.jar` as a shared library.
- 30 native libs bundled inside the APK itself (`extractNativeLibs=false`).
- Feature flags are read from props like `oplus.feature.*.support` and
  `ro.camera.hfr.enable`; OPlus config XMLs on this device are nearly empty.

## 4. Patches applied

1. **OplusCamera.apk** (apktool 2.10 rebuild):
   - removed `android:testOnly="true"`
   - added `<uses-library>`: `com.oplus.framework`, `com.oplus.support-wrapper`,
     `com.oplus.camera.unit.sdk` (all `required=false`)
   - zipaligned + signed with AOSP **test platform key** (cert SHA256
     `c8a2e9bccf597c2fb6dc66bee293fc13f2fc47ec77bc6b2b0d52c11f51192ab8`)
2. **oplus-framework-res.apk**:
   - binary string-pool patch: `android.uid.system` → `oplus.fwres.shared`
     (same length, no structural change), re-signed with test platform key.
   - the original unmodified copy is also shipped at `/system/framework/` for
     `AssetManager.addAssetPath`-style loading.
3. Module XMLs: shared-library declarations, privapp permissions, hidden-API
   whitelist, default runtime grants (CAMERA/RECORD_AUDIO/storage/phone state).

## 5. Known gaps to attack in v1.1+

- `oplus-framework-res` is only usable via package context / asset path — ColorOS
  also injects it into the system resource table (patched `libandroid_runtime`),
  which we can't do without a ROM-level patch. Views that resolve framework-attached
  resource IDs may misbehave.
- Hidden API policy: relies on sysconfig whitelist + low targetSdk. If the ROM
  enforces differently, LSPosed `HiddenApiBypass` is the fallback.
- Stock vendor-tag-based features (AI scene, watermark, MTK APU) need vendor
  services that don't exist on AOSP — expected to stay broken.
- `com.oplus.oguard` strings in the dex hint at integrity checks; watch for
  self-verification behavior in logs on first launch.
