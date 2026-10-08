# Handoff: cairn_ui 0.2.0 → update cairn_site

Written for: a Claude session working in the `cairn_site` repo
(<https://github.com/rlphjyson/cairn_site>, a Flutter web app built with
`cairn_ui`). Source of truth for everything below is the `cairn_ui` repo
(<https://github.com/rlphjyson/cairn_ui>), tag `v0.2.0`.

## What happened

`cairn_ui` went **0.1.1 → 0.2.0** and **45 → 65 components**. The 20 new
components are ported from daisyUI's catalogue (shapes shadcn/ui lacks), but
built entirely from Cairn's tokens: same theming, dark mode and radius scale.
Nothing existing changed. 0.2.0 is **published on pub.dev** (2026-10-08; may take
~10 min to appear). Repo state: 172 tests, 14 new golden sheets generated on the
Linux runner, analyze and format clean.

## Your job in cairn_site

1. Bump the dependency to `cairn_ui: ^0.2.0` and run `flutter pub get`.
2. Add the 20 components (below) to the site's component directory/catalogue,
   each live and interactive, in the same style as the existing 45. The easiest
   reference for demos is `example/lib/sections/extended_section.dart` in
   `cairn_ui`: copy and adapt those snippets.
3. Add the new `CairnTone` token (below) to the site's tokens/style-guide page.
4. Update any hard-coded "45 components" copy to **65**.
5. Add a **"Templates — coming soon"** area for the roadmap item below. Do not
   build the templates yet unless asked.

## Roadmap to record on the site (future, not built)

**Flutter web and mobile templates will be provided on Cairn Site.**
- Web set: landing page, dashboard, docs shell, auth screens.
- Mobile set: onboarding, tab-bar app shell (using `CairnDock`), settings, chat.
- Copy-and-run, themed purely via `CairnTheme`, light and dark included.
- The Extended components (Navbar, Dock, Hero, Stats, Steps, Chat Bubble, List)
  exist largely to make these templates possible without one-off widgets.
- Status: planned. Nothing in the `cairn_ui` package depends on it.

## New components (all exported from `package:cairn_ui/cairn_ui.dart`)

| Component | Key API | Notes |
| --- | --- | --- |
| `CairnStat`, `CairnStats` | `title`, `value`, `description?`, `figure?`, `actions?`; `CairnStats(children, direction)` | Stats groups children with 1px dividers in a bordered card. |
| `CairnStatus` | `tone`, `size=8`, `ping=false`, `semanticLabel` | Tone dot; `ping` pulses forever, so don't use it in goldens. |
| `CairnSteps` + `CairnStep` | `steps`, `current`, `direction`, `tone`, `onStepTap` | Only completed steps are tappable. |
| `CairnTimeline` + `CairnTimelineItem` | item: `title`, `description?`, `time?`, `icon?`, `tone` | Marker rail with connecting hairline. |
| `CairnChatBubble` | `child`, `side` (`CairnChatSide.received/sent`), `avatar?`, `author?`, `footer?` | Capped at 75% width; aligns itself in its parent. |
| `CairnRating` | `value`, `onChanged?`, `count=5`, `size=20`, `allowHalf`, `tone` | Null `onChanged` is read-only; arrow keys/Home/End step the value. |
| `CairnRadialProgress` | `value` (0–1), `size=64`, `thickness=6`, `tone`, `showValue`, `child?` | Animated ring. |
| `CairnCountdown`, `CairnCountdownDigits` | `duration`, `onComplete?`; digits: `value`, `minDigits` | Ticks once a second via a Timer; days/hours blocks show only if the duration needs them. |
| `CairnIndicator` | `child`, `indicator`, `placement` (`CairnIndicatorPlacement`), `offset` | Badge pinned to a corner; doesn't affect layout. |
| `CairnStack` | `children` (top first), `offset`, `scaleStep` | Overlapping layers or an avatar pile. |
| `CairnSwap` | `value`, `onChanged`, `on`, `off`, `effect` (`CairnSwapEffect.fade/rotate/flip`) | Controlled two-face toggle. |
| `CairnNavbar` | `start?`, `center?`, `end?`, `height=56`, `bordered`, `color?` | Centre is truly centred on the bar. |
| `CairnDock` + `CairnDockItem` | `items`, `index`, `onChanged`; item: `icon`, `label`, `badge?` | Mobile bottom nav, 64px. Needs ≥2 items. |
| `CairnHero` | `title`, `description?`, `eyebrow?`, `actions`, `alignment`, `muted`, `background?`, `padding` | 36rem measure on the description. |
| `CairnDiff` | `before`, `after`, `initialPosition`, `aspectRatio?`, `onChanged?` | Draggable divider; arrow keys/Home/End. |
| `CairnFileInput` | `fileName?`, `onBrowse?`, `onClear?`, `placeholder`, `buttonLabel`, `invalid` | Draws the control only. Wire `onBrowse` to `file_picker` or a web input. cairn_ui takes no dependencies. |
| `CairnList` + `CairnListItem` | list: `children`, `bordered`; item: `title`, `subtitle?`, `leading?`, `trailing?`, `onTap?`, `selected` | |
| `CairnLink` | `child`, `onPressed`, `muted`, `underline` | Doesn't navigate; call your router/`url_launcher` in `onPressed`. |
| `CairnFab` + `CairnFabAction` | `icon`, `onPressed?`, `actions`, `semanticLabel`; action: `icon`, `label`, `onPressed` | Non-empty `actions` makes it a speed dial. Position it yourself (`Align`/`Positioned`). |
| `CairnMockupWindow`, `CairnMockupBrowser`, `CairnMockupCode`, `CairnMockupPhone` | window: `title?`, `child`; browser: `url?`, `child`; code: `lines`, `prefix`, `highlight`; phone: `child`, `width=280` | Frames for showcasing content on the site. |

Also added: `CairnIconData.plus`.

## New token: `CairnTone` (`lib/src/tokens/tones.dart`)

shadcn's palette stops at primary/secondary/destructive, so state-bearing
components needed more. `enum CairnTone { neutral, primary, success, warning,
info, destructive }`, resolved by `CairnToneColors.resolve(theme, tone)` to a
`CairnToneColor(fill, onFill)`. success/warning/info are authored in OKLCH with
light and dark values (green-600/400, amber-500/400, blue-600/400). Worth a
swatch row on the site's tokens page.

## Gotchas learned while building (apply on the site too)

- **Never mount a repeating animation in a golden or `pumpAndSettle`**: `CairnStatus(ping: true)` repeats forever.
- **`CairnCountdown` owns a Timer.** Dispose by removing it from the tree; in
  tests, pump the tree away to avoid "timer still pending".
- **Semantics:** a node with increase/decrease actions needs both
  `increasedValue` and `decreasedValue` (this crashed `CairnDiff` once).
- **AnimationControllers must be created in `initState`, not as lazy `late final`
  fields**, or `dispose()` builds the ticker on a deactivated element and throws
  (the same bug fixed in 0.1.1 for ContextMenu).
- Mounting the whole catalogue on one page is a good smoke test for this class
  of bug; the 0.1.1 fixes were found that way in cairn_site.
- Golden images are **Linux-only**. Never commit ones generated on Windows/macOS;
  use the `update-goldens` workflow with `commit=true`.

## Where things live in cairn_ui

- Components: `lib/src/components/<name>/<name>.dart`; barrel `lib/cairn_ui.dart`.
- Behaviour tests: `test/components/extended_test.dart` (42).
- Goldens: `test/goldens/extended_goldens_test.dart` → `test/goldens/goldens/*.png`.
- Demo catalogue: `example/lib/sections/extended_section.dart` (the "Extended" tab).
- Docs: `README.md` (Components table, Extended note, Roadmap), `CHANGELOG.md`
  (0.2.0), `doc/images/cairn docs.md` (technical docs, sections 8–9).

## Verification checklist for the cairn_site session

- `flutter pub get` resolves `cairn_ui 0.2.0` (if not yet on pub.dev, wait or
  use a git dependency on tag `v0.2.0`).
- `flutter analyze` clean; site builds for web.
- Every new component has a live demo; dark mode checked.
- Component count copy updated to 65; Templates "coming soon" noted.
