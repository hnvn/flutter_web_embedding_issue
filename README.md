# Flutter web × Android WebView — minimal reproduction

Minimal Flutter **web** app (CanvasKit) for [flutter/flutter](https://github.com/flutter/flutter/issues) reports.

**Live demo:** https://hnvn.github.io/flutter_web_embedding_issue/

## Issues demonstrated

1. **Blank CJK `Text`** in Android WebView (layout OK, glyphs missing)
2. **Incomplete `RepaintBoundary.toImage()`** for off-screen widgets (caption text missing)
3. **`Expanded` reports `maxHeight: 0`** inside a bounded `Column` in WebView

Works in Chrome on the same device; fails in embedded WebView (`; wv)` UA).

---

## Deploy to GitHub Pages

### One-time setup (GitHub repo settings)

1. Open https://github.com/hnvn/flutter_web_embedding_issue/settings/pages
2. **Build and deployment** → Source: **GitHub Actions**

### Automatic deploy

Push to `main` — workflow `.github/workflows/deploy-pages.yml` builds and deploys.

### Local build

```bash
bash scripts/build_web.sh
# output: build/web
```

From zap-quiz monorepo:

```bash
bash scripts/build_webview_repro_web.sh
```

---

## Firebase Test Lab (WebView harness)

Use the **zap-quiz WebView harness** APK to record video of this demo in a real Android WebView.

### 1. Deploy this app (see above)

Confirm https://hnvn.github.io/flutter_web_embedding_issue/ loads in desktop Chrome.

### 2. Build harness APKs (from zap-quiz repo)

```bash
bash scripts/build_webview_harness_apk.sh
```

Default URL is already set to the GitHub Pages demo in `tools/webview_harness/app/build.gradle.kts`.

Override at runtime:

```bash
adb shell am start -n io.zap_24k.quiz.webview_harness/.MainActivity \
  --es quiz_url 'https://hnvn.github.io/flutter_web_embedding_issue/'
```

### 3. Run on Firebase Test Lab

1. **Test Lab** → **Instrumentation test**
2. Upload:
   - `build/webview_harness/zap-quiz-webview-harness-debug.apk`
   - `build/webview_harness/zap-quiz-webview-harness-debug-androidTest.apk`
3. Test: `io.zap_24k.quiz.webview_harness.QuizHarnessTest#waitForQuizToRender`
4. Pick devices (Samsung Fold, Pixel 7, etc.)
5. Review **video** at end of run — green “Quiz loaded” banner + repro UI

The harness waits for Flutter canvas (`main.dart.js` + `<canvas>`) up to 2 minutes.

---

## Manual WebView test

```bash
adb install build/webview_harness/zap-quiz-webview-harness-debug.apk
adb shell am start -n io.zap_24k.quiz.webview_harness/.MainActivity
```

`chrome://inspect` → inspect WebView → Console.

---

## Related

- Flutter issue draft: [zap-quiz `docs/flutter-issue/GITHUB_ISSUE_TEMPLATE.md`](https://github.com/24karat-io/zap-quiz/blob/main/docs/flutter-issue/GITHUB_ISSUE_TEMPLATE.md) (if applicable)
- Harness source: [zap-quiz `tools/webview_harness/`](https://github.com/24karat-io/zap-quiz/tree/main/tools/webview_harness)
