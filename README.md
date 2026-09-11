# Cairn UI

A modern, accessible Flutter component library built on a design token system
that is actually engineered: colours authored in OKLCH with a matched dark
theme, a radius scale derived proportionally from a single number, a type scale
that survives text scaling, and golden tests holding all of it in place.

45 components. No runtime dependencies beyond Flutter itself.

**Documentation site: <https://rlphjyson.github.io/cairn_site/>** — every
component live and interactive, plus composed blocks, charts and a typography
style guide. It is a Flutter web app
([source](https://github.com/rlphjyson/cairn_site)) built *with* this library:
its navigation, tabs, command palette, code-block toasts and directory table
are all Cairn widgets doing a real job.

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

## How Cairn is built

Most component libraries are a pile of widgets that happen to look alike.
Cairn is a token system with widgets on top, which is a different thing: the
consistency is structural rather than maintained by hand. Three claims, each
of them checkable rather than aspirational:

1. **No component hardcodes a number that should come from a token.** Every
   padding, radius, duration and colour resolves through the token layer.
2. **Every place a CSS-shaped design idea meets Flutter's rendering model is
   resolved explicitly** and documented where the two disagree — of which there
   are more than you would expect.
3. **Golden tests lock the result down**, so the implementation cannot drift.

### 1. The token layer

| File | Contents |
| --- | --- |
| `lib/src/tokens/oklch.dart` | `oklch()` → `Color` conversion |
| `lib/src/tokens/colors.dart` | All 19 semantic slots, light and dark, each annotated with the `oklch()` string it was authored as |
| `lib/src/tokens/spacing.dart` | A `0.25rem` (4 logical pixel) base scale |
| `lib/src/tokens/radius.dart` | The proportional radius scale, and `CairnRadiusScale` for custom bases |
| `lib/src/tokens/typography.dart` | Font sizes, line-height ratios, weights, tracking |
| `lib/src/tokens/shadows.dart` | The shadow scale plus the CSS-blur conversion |
| `lib/src/tokens/motion.dart` | Durations and easing curves |

Each colour records its authored value next to the converted constant:

```dart
/// `primary` = `oklch(0.205 0 0)` — `#171717` (neutral-900).
static const Color lightPrimary = Color(0xFF171717);
```

Four decisions in there are worth calling out, because each of them is a place
where the obvious choice is the worse one.

- **Colours are authored in OKLCH, not HSL or hex.** OKLCH is perceptually
  uniform: an equal step in lightness reads as an equal step in brightness at
  every hue. That is what lets the light and dark themes be two readings of one
  ramp and stay balanced by construction rather than by eye. The conversion
  lives in the package, so the provenance of every colour is checkable —
  `test/tokens/oklch_test.dart` re-derives every baked constant from its
  `oklch()` string.

- **The radius scale is multiplier-based.** Every step is a fixed multiple of a
  single base: `0.6`, `0.8`, `1`, `1.4`, `1.8`, `2.2`, `2.6`. The obvious
  alternative — pixel offsets from the base (`base - 4`, `base + 4`) — gives
  identical numbers at the 10px default and falls apart the moment the base is
  retuned: a compact 4px theme would produce a *negative* small radius.
  `CairnRadius.scaled()` stays proportional at any base, so changing
  `CairnTheme.radius` rescales the whole library coherently.

- **The achromatic ramp lands exactly on Tailwind's published `neutral`
  palette.** `oklch(0.145 0 0)` is `#0A0A0A` (neutral-950), `oklch(0.922 0 0)`
  is `#E5E5E5` (neutral-200), and so on down the scale. That is both an
  independent check that the OKLab pipeline is correct — a subtly wrong matrix
  would drift by a few units and miss — and a convenience, since Cairn's greys
  then sit flush against a Tailwind-flavoured design. `test/tokens/tokens_test.dart`
  asserts it.

- **Tokens are named for their role, never their appearance.** A component asks
  for *the foreground that belongs on a destructive surface*, not for white.
  That is the whole reason overriding one slot re-themes everything that reads
  it, and it is why `destructiveForeground` exists as a slot at all rather than
  being a hardcoded white inside Button and Badge.

### 2. Where CSS intuitions and Flutter's rendering model disagree

Cairn's tokens are authored in the vocabulary design systems actually use —
`rem`, `oklch()`, `box-shadow`, line heights in absolute units. Converting that
vocabulary into Flutter is where the interesting bugs live, because several of
these conversions are wrong if you carry the numbers across literally. Each is
implemented and commented in the source.

**Blur radius means different things.** CSS defines a shadow's blur as a
Gaussian with standard deviation **half** the stated radius. Flutter converts
`BoxShadow.blurRadius` to a sigma with `radius * 0.57735 + 0.5`. Putting a CSS
`6px` blur straight into `blurRadius` yields a sigma ~50% too wide.
`CairnShadows.cssBlur()` inverts Flutter's formula so the rendered sigma is the
one the design called for.

**Outer shadows are clipped in CSS and not in Flutter.** CSS never paints an
outer `box-shadow` through its element; Flutter paints a blurred filled copy of
the shape behind the box with no clip. On a transparent form control — which is
most of Cairn's — that turns the smallest shadow in the scale into a grey wash
across the field, and turns the hard 3px focus ring into a solid fill over the
*entire* control instead of an outline around it. `CairnShadowed` paints shadows
through a clip that removes the shape's interior.

**A partial-strength token scales alpha, it does not set it.** "The input
colour at 30%" means 30% *of what it already is*. For an opaque token that is
the same as setting alpha to 0.30 — but Cairn's dark `input` token is already
`oklch(1 0 0 / 15%)`, so 30% of it is white at **4.5%**, not 30%.
`withOpacityModifier()` multiplies. Getting this wrong is a six-times-too-strong
grey fill on every dark-mode form control.

**`Container(alignment:)` expands to fill.** A Flutter `Container` with a
non-null `alignment` grows to its bounded constraints. Used to centre a button's
label it silently stretches every button to its parent's width — the opposite of
what a button should do, which is size to its own content. Cairn centres via the
child's own `mainAxisAlignment` or a `Center(widthFactor: 1)` instead, and
`test/components/sizing_test.dart` guards it.

**Line height is a ratio, not a length.** A type scale pairs a font size with an
absolute line height (14px text on a 20px line). Flutter's `TextStyle.height` is
a *multiple*, so the conversion is `20 / 14`. Storing the ratio is what keeps
intrinsic heights correct when the user scales text — the pixel value would
silently stop matching.

**A line height of exactly 1 is not Flutter's default.** Card, Dialog and Label
titles want their line box to be precisely the font size, so a single-line
heading sits optically centred against the controls beside it. Flutter's default
comes from font metrics (~1.2), so it has to be set explicitly or titles sit
low.

**Some values are deliberately not round.** The Switch track is **18.4** logical
pixels, because a 16px thumb has to clear a 1px border on both sides with a hair
of room and that is where the arithmetic lands. The Tabs track padding is 3px,
not a spacing step, because that is what makes the active tab sit flush inside
it. The Checkbox radius is a literal 4px rather than a scale step, because at
16px square a proportional radius rounds the box into a blob. Rounding any of
these to a nicer number is exactly the drift this library exists to avoid.

### 3. Golden tests as the enforcement mechanism

The token layer is what makes the first implementation correct. Golden tests are
what keep it correct.

`test/goldens/goldens_test.dart` renders every component as a **sheet** — all
variants and states in one image — in both light and dark, and byte-compares it
against a committed reference PNG. A change to a padding value, a colour or a
radius fails CI with a visual diff.

Two things make this reliable rather than flaky:

**Fonts are bundled, not borrowed from the OS.** `flutter test` loads no real
font by default — text lays out with a placeholder where every glyph is an
identical box, which tells you nothing about typography. Cairn ships Geist
(SIL OFL 1.1) under `test/fonts/` and registers it in
`test/flutter_test_config.dart`. Because the font comes from the repository,
text shapes identically everywhere.

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
(Cairn has no ripple; its interactions are colour and shadow transitions only),
and Material 3's *filled* `TextField` default turned off, since Cairn inputs are
transparent with the border doing the work.

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

---

## Accessibility

A component library that looks right and behaves wrong is worse than no library
at all, because it makes the wrong thing easy. Cairn treats keyboard and screen
reader behaviour as part of each component's definition rather than as a later
pass.

- **`:focus-visible`, not `:focus`.** A focus ring is a keyboard affordance:
  clicking a button must not show one, tabbing to it must. Flutter's `hasFocus`
  cannot distinguish the two, so `CairnInteractive` combines focus state with
  `FocusManager.highlightMode` *and* tracks whether the focus change came from
  a pointer press.
- **Space and Enter both activate**, wired through `ActivateIntent` so it
  composes with a host app's own shortcuts rather than intercepting raw keys.
- **Focus trapping and restore** in Dialog, Alert Dialog, Sheet and Drawer.
  These push a `PopupRoute`, which gets Flutter's per-route `FocusScope` — plus
  back-gesture dismissal, which a mobile user will try first. Anchored surfaces
  (Popover, Dropdown Menu) use `OverlayPortal` instead so they stay out of the
  navigation stack.
- **Escape dismisses** every overlay — except Alert Dialog, which exists
  precisely to demand an explicit choice.
- **Roving focus** in Radio Group and Tabs: one tab stop for the group, arrow
  keys to move within it, so a ten-option group does not cost ten tab presses.
- **Slider** exposes increase/decrease actions with correct `increasedValue` /
  `decreasedValue` announcements, and supports arrow keys plus Home/End.
- **Disabled means inert.** A disabled control is genuinely removed from hit
  testing and focus traversal, not just painted grey — and so is its subtree.
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
| Command | Command palette with keyword matching |
| Context Menu | Right-click and long-press, anchored to the pointer |
| Data Table | Sort, filter, paginate — built on Table |
| Date Picker | Calendar in a Popover |
| Dialog | Focus trapped, Escape to dismiss |
| Drawer | Bottom sheet with grab handle and drag-to-dismiss |
| Dropdown Menu | Labels, separators, shortcuts, destructive items |
| Empty | Dashed border (hand-painted; Flutter's `Border` can't) |
| Form Field | Layout only — Flutter already has `Form` validation |
| Hover Card | Open and close grace periods |
| Input | 36px tall, transparent, 3px focus ring |
| Input OTP | One hidden field behind painted slots, so paste works |
| Kbd / Kbd Group | Sans, not monospace |
| Label | Line height of exactly 1 |
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
| Skeleton | Two-second pulse, respects reduced motion |
| Slider | Keyboard driven, 4px halo |
| Spinner | Constant-speed rotation, respects reduced motion |
| Switch | The derived 18.4px track |
| Table | 8px cells, 40px header |
| Tabs | Filled and line variants |
| Textarea | Auto-grows with its content |
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

- **[Geist](https://vercel.com/font)** by Vercel — bundled under `test/fonts/`
  for deterministic golden tests, SIL OFL 1.1.
- **[Lucide](https://lucide.dev)** — the icon geometry redrawn in
  `lib/src/internal/icons.dart`. ISC licensed.

Cairn is not affiliated with or endorsed by either project. Full third-party
attribution is in [NOTICE.md](NOTICE.md).

## Licence

MIT — see [LICENSE](LICENSE).
