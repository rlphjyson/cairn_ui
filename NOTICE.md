# Notices and third-party attribution

Cairn UI is released under the MIT Licence; see [LICENSE](LICENSE) for the full
text. This file records third-party material and attribution, kept separate so
that automated licence detectors (pub.dev's `pana` among them) can recognise
`LICENSE` as unmodified MIT.

## Bundled assets

- **[Geist](https://vercel.com/font)**, Copyright (c) 2023 Vercel, Inc.
  Bundled under `test/fonts/` and used **only** to make golden tests
  deterministic; it is not shipped to application binaries. Licensed under the
  SIL Open Font License 1.1 — full text at [`test/fonts/OFL.txt`](test/fonts/OFL.txt).

## Redrawn artwork

- **[Lucide](https://lucide.dev)** — the icons in
  `lib/src/internal/icons.dart` are drawn with a `CustomPainter` following
  Lucide's geometry (24x24 grid, 2px stroke, round caps and joins). No Lucide
  files are included. Lucide is ISC licensed.

Cairn UI is not affiliated with, sponsored by, or endorsed by either project.
