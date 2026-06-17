# Flutter web × Android WebView — minimal reproduction

Minimal Flutter **web** app (CanvasKit) to demonstrate issues filed with the Flutter team:

1. **Blank CJK `Text`** in Android WebView (layout OK, glyphs missing)
2. **Incomplete `RepaintBoundary.toImage()`** for off-screen widgets (caption text missing)
3. **`Expanded` reports `maxHeight: 0`** inside a bounded `Column` in WebView

Works in Chrome on the same device; fails in embedded WebView (`; wv)` UA).

## Build

```bash
cd examples/webview_repro
flutter pub get
flutter build web --release
```

Serve `build/web` (HTTPS recommended):

```bash
cd build/web
python3 -m http.server 8080
```

Or deploy to any static host and open the URL from a WebView shell.

## Test in Android WebView

### Option A — zap-quiz WebView harness

From repo root:

```bash
bash scripts/build_webview_harness_apk.sh
```

Install the harness APK, then override the URL:

```bash
adb shell am start -n io.zap_24k.quiz.webview_harness/.MainActivity \
  --es quiz_url 'https://YOUR_HOST/webview_repro/index.html'
```

### Option B — any Android app with WebView

```kotlin
webView.settings.javaScriptEnabled = true
webView.settings.domStorageEnabled = true
webView.loadUrl("https://YOUR_HOST/webview_repro/index.html")
```

Enable USB debugging → `chrome://inspect` → inspect WebView console.

## Expected vs actual

| Check | Chrome (mobile) | Android WebView |
|-------|-----------------|-----------------|
| On-screen Japanese text | Visible | Often **blank** |
| Capture preview caption | Visible | Often **missing** |
| Expanded maxHeight | > 0 (e.g. 132) | Often **0.0** (red) |

## Related

- GitHub issue draft: [`docs/flutter-issue/GITHUB_ISSUE_TEMPLATE.md`](../../docs/flutter-issue/GITHUB_ISSUE_TEMPLATE.md)
- Production workarounds: [`docs/lessons/webview-embedded-quiz-fixes.md`](../../docs/lessons/webview-embedded-quiz-fixes.md)
