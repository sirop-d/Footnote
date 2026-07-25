# Footnote

Re-attach **C2PA provenance** to AI-generated images so platforms like **X (Twitter)** can show the **“✨ Made with AI”** label again — after Photoshop, upscaling, or other tools strip the original tag.

> Honest disclosure only. For images you actually made with AI. Not for faking labels on photos that are not AI-generated.

## Why

Finishing passes (retouch, upscale, re-export) often drop embedded AI provenance. Footnote writes a standard C2PA manifest (`c2pa.created` + IPTC `trainedAlgorithmicMedia`) so you can declare that honestly **right before upload**.

## Requirements (macOS)

- [Homebrew](https://brew.sh)
- `brew install c2patool`

## Quick start

### CLI

```bash
chmod +x Footnote.sh
./Footnote.sh path/to/image.jpg
# → path/to/image_ai.jpg  (original untouched)
```

### Drag & drop app

```bash
./scripts/build_macos_app.sh v003
./scripts/deploy_to_applications.sh   # optional: /Applications/Footnote.app
```

Then drop PNG/JPEG onto **Footnote** (Dock-friendly). Output: `basename_ai.ext` next to the original.

## Output naming

| Input | Output |
|-------|--------|
| `sample.jpg` | `sample_ai.jpg` |

Short `_ai` suffix for global readability.

## How it works (short)

X currently lights the AI label when a **valid C2PA** claim includes:

- action `c2pa.created`
- `digitalSourceType` = `trainedAlgorithmicMedia` (IPTC)

Issuer trust lists are **not** required for that UI (as of 2026-07-22 experiments). Footnote uses c2patool’s **test signing cert** (development / self-declaration). Platform rules may change.

## Project layout

| Path | Role |
|------|------|
| `Footnote_v003.sh` | Versioned source of truth |
| `Footnote.sh` | Stable CLI name (copy of current version) |
| `droplet_src_v003.applescript` | Droplet source (`path to me` → bundled script) |
| `Footnote.app` | Built droplet (script inside `Contents/Resources/`) |
| `scripts/build_macos_app.sh` | Build versioned + stable `.app` |
| `scripts/deploy_to_applications.sh` | Overwrite `/Applications/Footnote.app` |

## Disclaimer

- Use only on content you are allowed to mark as AI-generated.
- Does not copy OpenAI/Adobe/etc. signatures; it adds a **self-declared** C2PA claim.
- Extension must match real format (JPEG bytes named `.png` will fail).

## License

MIT — see [LICENSE](LICENSE).

## Credit

Built by [sirop](https://github.com/sirop-d) for personal workflow; shared so others can reuse or fork.
