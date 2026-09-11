# Cairn UI

A Flutter component library rebuilt to [shadcn/ui](https://ui.shadcn.com)'s
measurements — the same spacing, radii, colour tokens, type scale, shadows and
focus-ring treatment, translated from shadcn/ui's actual Tailwind source into
Flutter and held in place by golden tests.

45 components. No runtime dependencies beyond Flutter itself.

![The Cairn catalogue, Forms section](https://raw.githubusercontent.com/rlphjyson/cairn_ui/main/doc/images/catalog-forms.png)

<details>
<summary>More screenshots</summary>

Overlays, dark theme:

![Overlays in the dark theme](https://raw.githubusercontent.com/rlphjyson/cairn_ui/main/doc/images/catalog-overlays-dark.png)

Tokens:

![The token scales](https://raw.githubusercontent.com/rlphjyson/cairn_ui/main/doc/images/catalog-tokens.png)

Feedback and data, dark theme:

![Data table, calendar and toasts in the dark theme](https://raw.githubusercontent.com/rlphjyson/cairn_ui/main/doc/images/catalog-feedback-dark.png)

</details>

---

## Install

```yaml
dependencies:
  cairn_ui: ^0.1.0
```

## Quick start

```dart
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CairnTheme.materialTheme(CairnTheme.light),
      darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
      home: Scaffold(
        body: Center(
          child: CairnCard(
            width: 360,
            children: <Widget>[
              const CairnCardHeader(
                title: Text('Deploy your project'),
                description: Text('Ship to production in one click.'),
              ),
              CairnCardFooter(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CairnButton(
                    variant: CairnButtonVariant.outline,
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                  CairnButton(onPressed: () {}, child: const Text('Deploy')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Run the full catalogue:

```bash
cd example && flutter run
```

---

## What "pixel-perfect" honestly means here

Flutter rasterises with Skia/Impeller; a browser rasterises with its own engine
and its own font shaping. The two will **never** produce byte-identical
screenshots, and chasing that would be wasted effort. So this project does not
claim screenshot-identical rendering to ui.shadcn.com. What it does claim is
narrower and checkable:

1. **Every dimension is derived from shadcn/ui's real, current source** rather
   than eyeballed or remembered.
2. **Every conversion between CSS and Flutter semantics is explicit** and
   documented where the two disagree — of which there are more than you would
   expect.
3. **Golden tests lock the result down**, so the implementation cannot drift.

### 1. Where the numbers come from

The tokens were extracted from shadcn/ui's live repository and registry, not
from memory:

| Source | What was taken from it |
| --- | --- |
| `shadcn-ui/ui` → `apps/v4/registry/new-york-v4/ui/*.tsx` | Per-component Tailwind class strings (padding, height, gap, radius, font size, shadow, ring, transition) |
| `https://ui.shadcn.com/r/colors/neutral.json` | The canonical `cssVars.light` / `cssVars.dark` token values |
| `shadcn-ui/ui` → `packages/shadcn/src/utils/updaters/update-css-vars.ts` | The radius formula the CLI actually writes |
| Tailwind CSS v4 docs | The spacing base, type scale and box-shadow values |

Each token file records the source string next to the converted value, e.g.:

```dart
/// `--primary: oklch(0.205 0 0)` — `#171717` (neutral-900).
static const Color lightPrimary = Color(0xFF171717);
```

**Things that surprised me while doing this**, and that stale knowledge gets
wrong:

- **shadcn/ui is on OKLCH, not HSL.** The default theme moved off HSL during the
  Tailwind v4 rework. Anything still converting `hsl(var(--primary))` is out of
  date.
- **The radius scale is multiplier-based now.** The current CLI writes
  `--radius-sm: calc(var(--radius) * 0.6)` … `* 0.8`, `* 1.4`, not the older
  `calc(var(--radius) - 4px)` / `- 2px` / `+ 4px`. At the default
  `--radius: 0.625rem` the two happen to agree exactly (6 / 8 / 10 / 14px),
  which is presumably why the change went unnoticed — they only diverge once
  `--radius` is customised. `CairnRadius.scaled()` implements the multiplier
  form.
- **The docs site's theme is not the registry's theme.**
  `apps/v4/app/globals.css` overrides `--foreground` and `--primary` to pure
  black (`oklch(0% 0 0)`) for the site's own branding. The registry — what
  `npx shadcn init` actually writes into your project — uses `0.145` and
  `0.205`. Cairn follows the registry.
- **`--destructive-foreground` was dropped.** Current components hardcode
  `text-white` on destructive fills instead of reading a variable.
- A useful correctness check fell out of the OKLCH conversion: every achromatic
  step lands *exactly* on Tailwind's published `neutral` hex ramp
  (`oklch(0.145 0 0)` → `#0A0A0A` = neutral-950, `oklch(0.922 0 0)` → `#E5E5E5`
  = neutral-200, and so on). `test/tokens/tokens_test.dart` asserts this.

### 2. Where CSS and Flutter genuinely disagree

These are the conversions that are wrong if you copy the numbers across
literally. Each is implemented and commented in the source.

**Blur radius means different things.** CSS defines a shadow's blur as a
Gaussian with standard deviation **half** the stated radius. Flutter converts
`BoxShadow.blurRadius` to a sigma with `radius * 0.57735 + 0.5`. Pasting CSS's
`6px` into `blurRadius` yields a sigma ~50% too wide. `CairnShadows.cssBlur()`
inverts Flutter's formula so the rendered sigma matches the browser's.

**Outer shadows are clipped in CSS and not in Flutter.** CSS never paints an
outer `box-shadow` through its element; Flutter paints a blurred filled copy of
the shape behind the box with no clip. On shadcn/ui's `bg-transparent` form
controls that turns `shadow-xs` into a grey wash across the field — and turns
`focus-visible:ring-[3px]` (which compiles to `box-shadow: 0 0 0 3px`) into a
solid fill over the *entire* control instead of a 3px outline.
`CairnShadowed` paints shadows through a clip that removes the shape's interior.

**Tailwind's `/N` modifier scales alpha, it does not set it.** `bg-input/30`
compiles to `color-mix(in oklab, var(--input) 30%, transparent)`. For an opaque
token that is the same as setting alpha to 0.30 — but shadcn/ui's dark
`--input` is already `oklch(1 0 0 / 15%)`, so `dark:bg-input/30` is white at
**4.5%**, not 30%. `withOpacityModifier()` multiplies.

**`Container(alignment:)` expands to fill.** A Flutter `Container` with a
non-null `alignment` grows to its bounded constraints. Used to centre a
button's label it silently breaks `inline-flex` / `w-fit` sizing, stretching
every button to its parent's width. Cairn centres via the child's own
`mainAxisAlignment` or a `Center(widthFactor: 1)` instead, and
`test/components/sizing_test.dart` guards it.

**Line height is a ratio, not a length.** Tailwind pairs a font size with an
absolute line height (`text-sm` is `0.875rem / 1.25rem`). Flutter's
`TextStyle.height` is a *multiple*, so the conversion is `20 / 14`. Storing the
ratio keeps intrinsic heights correct when the user scales text.

**`leading-none` is not Flutter's default.** Card, Dialog and Label titles use
`line-height: 1`. Flutter's default comes from font metrics (~1.2), so it has
to be set explicitly or titles sit low.

**Some values are deliberately odd.** The Switch track is `h-[1.15rem]` —
**18.4** logical pixels. The Tabs track is `p-[3px]`. The Checkbox radius is a
literal `rounded-[4px]`, not a `--radius` step. Rounding any of these to a
"nicer" number is exactly the drift this library exists to avoid.

### 3. Golden tests as the enforcement mechanism

Token extraction makes the *first* implementation correct. Golden tests are
what keep it correct.

`test/goldens/goldens_test.dart` renders every component as a **sheet** — all
variants and states in one image — in both light and dark, and byte-compares it
against a committed reference PNG. A change to a padding value, a colour or a
radius fails CI with a visual diff.

Two things make this reliable rather than flaky:

**Fonts are bundled, not borrowed from the OS.** `flutter test` loads no real
font by default — text lays out with a placeholder where every glyph is an
identical box, which tells you nothing about typography. Cairn ships Geist (the
typeface shadcn/ui's own site uses, SIL OFL 1.1) under `test/fonts/` and
registers it in `test/flutter_test_config.dart`. Because the font comes from
the repository, text shapes identically everywhere.

**Goldens are generated and verified on one platform.** Even with identical
fonts, sub-pixel anti-aliasing can differ between operating systems. Rather
than weaken the comparison with a fuzzy threshold — which would let real
regressions through — Cairn enforces goldens on **Linux**, which is what CI
runs. On Windows and macOS the widgets are still built and pumped (so layout
errors and exceptions are caught), but the pixel comparison is skipped. Set
`CAIRN_FORCE_GOLDENS=1` to compare anyway.

#### Regenerating goldens

Because references must come from the same platform that verifies them, do not
run `--update-goldens` locally on Windows or macOS. Instead:

1. Go to **Actions → Update goldens → Run workflow**.
2. Download the `goldens` artifact and commit the files, or tick **commit** to
   have the workflow push them for you.

The workflow re-runs `flutter test` afterwards to prove the regenerated images
actually pass.

One more detail: golden capture pumps a **fixed number of frames** rather than
calling `pumpAndSettle`. Components with repeating animations — the Spinner,
the Skeleton pulse, the Input OTP caret, indeterminate Progress — never stop
scheduling frames, so `pumpAndSettle` times out. The harness also sets
`MediaQueryData.disableAnimations`, which those components honour, so they
render as one deterministic frame.

---

## Theming

`CairnTheme` is a `ThemeExtension`. That is a deliberate integration choice: an
inherited widget of Cairn's own would force host apps to nest two theme systems
and would break any Material widget already in use. Riding on
`ThemeData.extensions` instead means Cairn composes inside an ordinary
`MaterialApp`, Flutter animates theme transitions for free via
`ThemeExtension.lerp`, and `Theme.of(context)` stays the single lookup path.

```dart
MaterialApp(
  theme: CairnTheme.materialTheme(CairnTheme.light),
  darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
);
```

`materialTheme()` also aligns Material's own defaults with the Cairn tokens —
scaffold background, `ColorScheme`, text selection colours, no ink splash
(shadcn/ui has no ripple), and Material 3's *filled* `TextField` default turned
off, since shadcn/ui inputs are `bg-transparent`.

If you would rather wire it up yourself:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const <ThemeExtension<dynamic>>[CairnTheme.light],
  ),
);
```

Customise with `copyWith`. Changing `radius` rescales every component's corners
proportionally:

```dart
final theme = CairnTheme.light.copyWith(
  primary: const Color(0xFF3B82F6),
  radius: 4.0,
  fontFamily: 'Inter',
);
```

Components resolve tokens through `CairnTheme.of(context)`, which falls back to
`CairnTheme.light` rather than throwing — a widget dropped into an app with no
extension registered still renders correctly.

### The token layer

| File | Contents |
| --- | --- |
| `lib/src/tokens/oklch.dart` | `oklch()` → `Color` conversion |
| `lib/src/tokens/colors.dart` | All 19 semantic slots, light and dark, each annotated with its source `oklch()` string |
| `lib/src/tokens/spacing.dart` | Tailwind's `0.25rem` scale |
| `lib/src/tokens/radius.dart` | The `--radius` scale and `CairnRadiusScale` for custom bases |
| `lib/src/tokens/typography.dart` | Font sizes, line-height ratios, weights, tracking |
| `lib/src/tokens/shadows.dart` | The shadow scale plus the CSS-blur conversion |
| `lib/src/tokens/motion.dart` | Durations and Tailwind's easing curves |

No component hardcodes a number that should come from a token.

---

## Accessibility

shadcn/ui is built on Radix UI primarily *for their accessibility semantics*,
so matching the visuals without matching the behaviour would miss the point.

- **`:focus-visible`, not `:focus`.** shadcn/ui draws its ring with
  `focus-visible:`, so clicking a button must not show a ring while tabbing to
  it must. Flutter's `hasFocus` cannot distinguish the two, so
  `CairnInteractive` combines focus state with
  `FocusManager.highlightMode` *and* tracks whether the focus change came from
  a pointer press.
- **Space and Enter both activate**, matching Radix, wired through
  `ActivateIntent` so it composes with a host app's own shortcuts.
- **Focus trapping and restore** in Dialog, Alert Dialog, Sheet and Drawer.
  These push a `PopupRoute`, which gets Flutter's per-route `FocusScope` — plus
  back-gesture dismissal, which Radix has no equivalent of. Anchored surfaces
  (Popover, Dropdown Menu) use `OverlayPortal` instead so they stay out of the
  navigation stack.
- **Escape dismisses** every overlay — except Alert Dialog, which by design
  demands an explicit choice.
- **Roving focus** in Radio Group and Tabs: one tab stop for the group, arrow
  keys to move within it.
- **Slider** exposes increase/decrease actions with correct `increasedValue` /
  `decreasedValue` announcements, and supports arrow keys plus Home/End.
- **`disabled:pointer-events-none`** genuinely removes the subtree from hit
  testing, not just the component itself.
- **Reduced motion** is honoured by Skeleton, Spinner and the Input OTP caret.

---

## Components

| Component | Notes |
| --- | --- |
| Accordion | Single and multiple modes, 200ms height animation |
| Alert | Default and destructive, optical icon alignment |
| Alert Dialog | Not dismissible by Escape or barrier, by design |
| Aspect Ratio | Thin wrapper over Flutter's own |
| Avatar / Avatar Group | Fallback persists on image error |
| Badge | 5 variants |
| Breadcrumb | Responsive gap, current-page semantics |
| Button | 6 variants x 8 sizes |
| Calendar | Fixed 7x6 grid so height never jumps |
| Card | Header / content / footer slots |
| Carousel | `PageView`-backed, with indicators |
| Checkbox | Tristate (indeterminate) supported |
| Collapsible | The primitive under Accordion |
| Combobox | Searchable select |
| Command | cmdk-style palette, keyword matching |
| Context Menu | Right-click and long-press, anchored to the pointer |
| Data Table | Sort, filter, paginate — built on Table |
| Date Picker | Calendar in a Popover |
| Dialog | Focus trapped, Escape to dismiss |
| Drawer | Bottom sheet with grab handle and drag-to-dismiss |
| Dropdown Menu | Labels, separators, shortcuts, destructive items |
| Empty | Dashed border (hand-painted; Flutter's `Border` can't) |
| Form Field | Layout only — Flutter already has `Form` validation |
| Hover Card | Open and close grace periods |
| Input | `h-9`, transparent, 3px focus ring |
| Input OTP | One hidden field behind painted slots, so paste works |
| Kbd / Kbd Group | `font-sans`, not monospace |
| Label | `leading-none` |
| Menubar | Hover-to-switch once open |
| Menu primitives | Panel, item, checkbox item, label, separator |
| Navigation Menu | Arbitrary panel content |
| Pagination | Windowed range with ellipses |
| Popover | Flip and shift positioning |
| Progress | Determinate and indeterminate |
| Radio Group | Roving focus |
| Scroll Area | Configures Flutter's scrollbar rather than replacing it |
| Select | Menu matches trigger width |
| Separator | Decorative or semantic |
| Sheet | Four sides, asymmetric 500ms open / 300ms close |
| Skeleton | `animate-pulse` curve, respects reduced motion |
| Slider | Keyboard driven, `ring-4` halo |
| Spinner | `animate-spin`, respects reduced motion |
| Switch | The literal `h-[1.15rem]` track |
| Table | `p-2` cells, `h-10` header |
| Tabs | Filled and line variants |
| Textarea | Auto-grows, matching `field-sizing-content` |
| Toast | Host outlives the route that fired it |
| Toggle / Toggle Group | Single and multiple, joined or spaced |
| Tooltip | Opens on hover *and* keyboard focus |

### What this library deliberately does not do

It is a pure widget package, so a number of things commonly checked for in
application projects simply do not apply: there is no backend, no auth, no
analytics SDK, no network layer, no local database, no offline sync, no
platform channels and no native code. `platforms:` declares every target
Flutter supports because there is nothing platform-specific to break.

It also does not ship a form-validation engine (Flutter has `Form` and
`FormField`; competing with them would fight the framework), a theme-builder
UI, or icon assets — the handful of glyphs components need are drawn from
Lucide's geometry with a `CustomPainter`.

---

## Testing

```bash
flutter test                 # 114 tests
flutter analyze --fatal-infos --fatal-warnings
dart format --set-exit-if-changed .
```

Behaviour tests live in `test/components/`, goldens in `test/goldens/`, token
maths in `test/tokens/`.

---

## Credit

Cairn UI is an **independent implementation**. It contains no code from
shadcn/ui or Radix UI — React/Tailwind and Flutter/Dart share no code, so there
was nothing to copy even in principle. What was taken is *measurements*:
padding, radii, colour values, durations, and the behavioural contracts those
projects define.

- **[shadcn/ui](https://ui.shadcn.com)** by [shadcn](https://github.com/shadcn)
  — the design language, the token system and the component catalogue this
  library measures itself against. MIT licensed.
- **[Radix UI](https://www.radix-ui.com)** — the accessibility behaviour
  shadcn/ui is built on, and the contract Cairn reproduces in Flutter (focus
  management, roving focus, dismissal semantics). MIT licensed.
- **[Geist](https://vercel.com/font)** by Vercel — bundled under `test/fonts/`
  for deterministic golden tests, SIL OFL 1.1.
- **[Lucide](https://lucide.dev)** — the icon geometry redrawn in
  `lib/src/internal/icons.dart`. ISC licensed.

Cairn is not affiliated with or endorsed by any of them.

## Licence

MIT — see [LICENSE](LICENSE).
