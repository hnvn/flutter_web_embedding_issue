# Flutter web × Android WebView — minimal reproduction

Small Flutter **web** app (CanvasKit) for reporting issues to [flutter/flutter](https://github.com/flutter/flutter/issues).

**Live demo:** https://hunghd.dev/flutter_web_embedding_issue/  
**Mirror:** https://hnvn.github.io/flutter_web_embedding_issue/

## What it shows

1. **Blank CJK `Text`** in Android WebView (space reserved, glyphs missing)
2. **Incomplete `RepaintBoundary.toImage()`** for off-screen widgets
3. **`Expanded` reports `maxHeight: 0`** inside a bounded `Column`

Same URL works in Chrome on the device; fails in embedded WebView (`; wv)` user agent).

---

## Build

```bash
flutter pub get
bash scripts/build_web.sh
# output: build/web
```

Serve `build/web` over HTTPS, or push to `main` to deploy via GitHub Actions (see `.github/workflows/deploy-pages.yml`).

**GitHub Pages (one-time):** repo Settings → Pages → Source: **GitHub Actions**.

---

## Test in Android WebView

1. Open the live demo in **Chrome** on the phone (baseline).
2. Open the **same URL** in any Android **WebView** shell.
3. Compare: scroll behavior, Japanese text, Expanded probe (green vs red), capture preview.

**Remote debug:** `chrome://inspect` → select the WebView → Console.

**Example (generic WebView app via adb):**

```bash
adb shell am start -a android.intent.action.VIEW \
  -d 'https://hunghd.dev/flutter_web_embedding_issue/'
```

(Use whatever WebView host app you have; the repro URL is all that matters.)

---

## Source

Standalone repo: https://github.com/hnvn/flutter_web_embedding_issue
