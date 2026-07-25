#!/bin/zsh
# Build Footnote_vNNN.app (versioned) and Footnote.app (Dock / Applications name).
# 担当AI名: Cursor / ソル
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION_TAG="${1:-v003}"
SRC_SH="$ROOT/Footnote_${VERSION_TAG}.sh"
SRC_DROPLET="$ROOT/droplet_src_${VERSION_TAG}.applescript"
OUT_VERSIONED="$ROOT/Footnote_${VERSION_TAG}.app"
OUT_STABLE="$ROOT/Footnote.app"

if [[ ! -f "$SRC_SH" ]]; then
  echo "Missing: $SRC_SH" >&2
  exit 1
fi
if [[ ! -f "$SRC_DROPLET" ]]; then
  echo "Missing: $SRC_DROPLET" >&2
  exit 1
fi

chmod +x "$SRC_SH"
# Stable CLI name next to versioned正本
cp -f "$SRC_SH" "$ROOT/Footnote.sh"
chmod +x "$ROOT/Footnote.sh"

rm -rf "$OUT_VERSIONED" "$OUT_STABLE"
osacompile -o "$OUT_VERSIONED" "$SRC_DROPLET"
mkdir -p "$OUT_VERSIONED/Contents/Resources"
cp -f "$SRC_SH" "$OUT_VERSIONED/Contents/Resources/Footnote.sh"
chmod +x "$OUT_VERSIONED/Contents/Resources/Footnote.sh"

# Dock固定名（版なし）
cp -R "$OUT_VERSIONED" "$OUT_STABLE"

echo "Built: $OUT_VERSIONED"
echo "Built: $OUT_STABLE"
echo "Stable CLI: $ROOT/Footnote.sh"
