#!/bin/zsh
# =============================================================
# Footnote — Re-attach C2PA provenance so X shows "✨ Made with AI"
# VERSION: Footnote_v003
# 担当AI名: Cursor / ソル
# 改訂ログ:
#   v003_20260725_215738 常用配置: .app に sh 同梱（path to me）。
#                         /Applications/Footnote.app 上書き配備。
#                         安定名 Footnote.sh。GitHub 公開用に整備。
#   v002_20260725_214611 出力サフィックス `_✨AIタグ` → `_ai`。
#   v001_20260722_115810 初版。自己署名C2PA付与。
# 仕組み:
#   Xの「✨AIで生成」は、有効なC2PA内の c2pa.created +
#   digitalSourceType=trainedAlgorithmicMedia を見て点灯する
#   （発行者不問・20260722 sirop実験）。本ツールはその形式を
#   c2patool テスト証明書で自己署名付与する。
#   偽装ではなく「実際にAI生成した画像への誠実な自己申告」専用。
# 使い方:
#   ./Footnote.sh 画像1.png [画像2.jpg ...]
#   または Footnote.app へドロップ
#   出力: 同じフォルダに「元名_ai.拡張子」（元ファイルは変更しない）
# =============================================================

VERSION="Footnote_v003"
# Prefer Homebrew c2patool; fall back to PATH
if [[ -x "/opt/homebrew/bin/c2patool" ]]; then
  C2PATOOL="/opt/homebrew/bin/c2patool"
elif [[ -x "/usr/local/bin/c2patool" ]]; then
  C2PATOOL="/usr/local/bin/c2patool"
else
  C2PATOOL="$(command -v c2patool 2>/dev/null || true)"
fi
OUT_SUFFIX="_ai"

if [[ -z "$C2PATOOL" || ! -x "$C2PATOOL" ]]; then
  echo "Error: c2patool not found. Install with: brew install c2patool" >&2
  exit 1
fi
if [[ $# -eq 0 ]]; then
  echo "Usage: $VERSION IMAGE [IMAGE...]" >&2
  echo "Example: sample.jpg → sample_ai.jpg" >&2
  exit 1
fi

NOW_ISO="$(date -u "+%Y-%m-%dT%H:%M:%SZ")"
MANIFEST="$(mktemp -t footnote_manifest).json"
cat > "$MANIFEST" <<EOF
{
  "claim_generator_info": [
    { "name": "sirop Footnote", "version": "0.0.3" }
  ],
  "title": "AI-generated image (self-declared provenance)",
  "assertions": [
    {
      "label": "c2pa.actions.v2",
      "data": {
        "actions": [
          {
            "action": "c2pa.created",
            "when": "$NOW_ISO",
            "softwareAgent": { "name": "AI image workflow (ChatGPT Image / Higgsfield Nano Banana Pro)", "version": "1.0" },
            "digitalSourceType": "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia"
          }
        ]
      }
    }
  ]
}
EOF

ok=0; ng=0
for src in "$@"; do
  if [[ ! -f "$src" ]]; then
    echo "Skip (not found): $src" >&2; ((ng++)); continue
  fi
  dir="${src:h}"; base="${src:t:r}"; ext="${src:e}"
  if [[ "$base" == *"_✨AIタグ" ]]; then
    base="${base%_✨AIタグ}"
  fi
  out="$dir/${base}${OUT_SUFFIX}.$ext"
  if [[ "$out" == "$src" ]]; then
    echo "Skip (same in/out): $src" >&2; ((ng++)); continue
  fi
  if "$C2PATOOL" "$src" -m "$MANIFEST" -o "$out" -f > /dev/null 2>&1; then
    touch -r "$src" "$out"
    echo "✅ $out"
    ((ok++))
  else
    [[ -f "$out" && ! -s "$out" ]] && rm -f "$out"
    echo "❌ Failed: $src" >&2; ((ng++))
  fi
done

rm -f "$MANIFEST"
echo "--- $VERSION done: ok $ok / fail $ng"
