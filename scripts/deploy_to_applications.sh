#!/bin/zsh
# Overwrite /Applications/Footnote.app with the mother-ship Footnote.app
# Dock can stay pinned to /Applications/Footnote.app across version bumps.
# 担当AI名: Cursor / ソル
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/Footnote.app"
DEST="/Applications/Footnote.app"

if [[ ! -d "$SRC" ]]; then
  echo "Missing $SRC — run scripts/build_macos_app.sh first" >&2
  exit 1
fi

# Ensure Resources/Footnote.sh is present
if [[ ! -x "$SRC/Contents/Resources/Footnote.sh" ]]; then
  echo "Footnote.app is incomplete (no Resources/Footnote.sh). Rebuild." >&2
  exit 1
fi

rm -rf "$DEST"
cp -R "$SRC" "$DEST"
echo "Deployed: $DEST"
echo "Tip: drag /Applications/Footnote.app to Dock once; later bumps only overwrite this path."
