# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Fixed

- `CairnContextMenu` threw "Looking up a deactivated widget's ancestor is
  unsafe" when it was disposed without ever having been opened. Its
  `AnimationController` was a `late final` field, so a menu nobody right-clicked
  created its controller for the first time inside `dispose()` — against an
  already-deactivated element, where `createTicker` walks the tree looking for
  a `TickerMode`. The controller is now built in `initState`, matching every
  other stateful component in the library. Found by mounting the whole
  catalogue on one page in `cairn_site` and navigating away from it.

## 0.1.0

First release. 45 components on an engineered design token layer, with golden
tests enforcing appearance in both themes.

### Added

**Tokens** (`lib/src/tokens/`)

- OKLCH to sRGB conversion, since the palette is authored in `oklch()` for
  perceptual uniformity. Values round-trip exactly onto Tailwind's published
  `neutral` ramp.
- A 4 logical pixel spacing scale, a proportional radius scale (every step a
  multiple of one base), a type scale (rem line heights as Flutter `height`
  multiples), motion curves and the box-shadow scale.
- Shadow conversion that inverts Flutter's `radius -> sigma` formula, so a CSS
  blur renders at the Gaussian sigma a browser would produce.

**Theme** (`lib/src/theme/`)

- `CairnTheme`, a `ThemeExtension` carrying all 19 semantic colour slots plus
  radius and font family, with `light` and `dark` presets.
- `CairnTheme.materialTheme()`, which builds a `ThemeData` whose Material
  defaults agree with the Cairn tokens.
- `withOpacityModifier`, which scales a colour's existing alpha rather than
  replacing it, so a partial-strength token means a fraction of what the token
  already is.

**Components** — Accordion, Alert, Alert Dialog, Aspect Ratio, Avatar, Avatar
Group, Badge, Breadcrumb, Button, Calendar, Card, Carousel, Checkbox,
Collapsible, Combobox, Command, Context Menu, Data Table, Date Picker, Dialog,
Drawer, Dropdown Menu, Empty, Form Field, Hover Card, Input, Input OTP, Kbd,
Label, Menubar, Menu primitives, Navigation Menu, Pagination, Popover,
Progress, Radio Group, Scroll Area, Select, Separator, Sheet, Skeleton, Slider,
Spinner, Switch, Table, Tabs, Textarea, Toast, Toggle, Toggle Group, Tooltip.

**Testing**

- Widget tests covering interaction, keyboard handling, focus trapping and
  intrinsic sizing.
- Golden sheets for every component in both themes, with a bundled Geist font
  so text shapes identically across machines.

[Unreleased]: https://github.com/rlphjyson/cairn_ui
