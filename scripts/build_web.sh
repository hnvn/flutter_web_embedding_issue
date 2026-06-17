#!/usr/bin/env bash
set -euo pipefail

# Build Flutter web for GitHub Pages (project site).
# Live URL: https://hnvn.github.io/flutter_web_embedding_issue/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE_HREF="${BASE_HREF:-/flutter_web_embedding_issue/}"

cd "$ROOT"
flutter pub get
flutter build web --release --base-href="$BASE_HREF"

cp build/web/index.html build/web/404.html
touch build/web/.nojekyll

echo ""
echo "Build ready: $ROOT/build/web"
echo "GitHub Pages URL: https://hnvn.github.io/flutter_web_embedding_issue/"
echo ""
echo "Test locally:"
echo "  cd build/web && python3 -m http.server 8080"
echo "  open http://localhost:8080${BASE_HREF}"
