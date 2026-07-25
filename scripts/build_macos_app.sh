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

# Custom app icon (assets/Footnote.icns → droplet.icns)
# osacompile also emits Assets.car which can override .icns in Finder — remove it.
ICON_ICNS="$ROOT/assets/Footnote.icns"
for APP in "$OUT_VERSIONED" "$OUT_STABLE"; do
  rm -f "$APP/Contents/Resources/Assets.car"
  if [[ -f "$ICON_ICNS" ]]; then
    cp -f "$ICON_ICNS" "$APP/Contents/Resources/droplet.icns"
  fi
  # Stable display identity
  /usr/libexec/PlistBuddy -c 'Set :CFBundleName Footnote' "$APP/Contents/Info.plist" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c 'Add :CFBundleName string Footnote' "$APP/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName Footnote' "$APP/Contents/Info.plist" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c 'Add :CFBundleDisplayName string Footnote' "$APP/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier jp.sirop.Footnote' "$APP/Contents/Info.plist" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c 'Add :CFBundleIdentifier string jp.sirop.Footnote' "$APP/Contents/Info.plist"
  touch "$APP" "$APP/Contents/Info.plist"
done
if [[ -f "$ICON_ICNS" ]]; then
  echo "Icon: $ICON_ICNS → droplet.icns (Assets.car removed)"
else
  echo "Note: no $ICON_ICNS — kept osacompile default icns; Assets.car still removed" >&2
fi

echo "Built: $OUT_VERSIONED"
echo "Built: $OUT_STABLE"
echo "Stable CLI: $ROOT/Footnote.sh"
