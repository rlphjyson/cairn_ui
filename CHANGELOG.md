# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.0

First release. 45 components built to shadcn/ui's measurements, with a token
layer extracted from shadcn/ui's live registry and golden tests enforcing
appearance.

### Added

**Tokens** (`lib/src/tokens/`)

- OKLCH to sRGB conversion, since shadcn/ui's default theme is authored in
  `oklch()`. Values round-trip exactly onto Tailwind's published `neutral`
  ramp.
- Tailwind's spacing scale (`--spacing: 0.25rem`), radius scale (the current
  multiplier formula), type scale (rem line heights as Flutter `height`
  multiples), motion curves and the box-shadow scale.
- Shadow conversion that inverts Flutter's `radius -> sigma` formula, so a CSS
  blur renders at the Gaussian sigma a browser would produce.

**Theme** (`lib/src/theme/`)

- `CairnTheme`, a `ThemeExtension` carrying all 19 semantic colour slots plus
  radius and font family, with `light` and `dark` presets.
- `CairnTheme.materialTheme()`, which builds a `ThemeData` whose Material
  defaults agree with the Cairn tokens.
- `withOpacityModifier`, reproducing Tailwind's `/N` opacity modifier, which
  scales a colour's existing alpha rather than replacing it.

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
