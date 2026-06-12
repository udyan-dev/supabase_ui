# supabase_ui

> A token-driven, performance-first Flutter design system inspired by
> [Supabase](https://supabase.com/design-system), with a
> [Lucide](https://lucide.dev) icon pipeline that ships **icon names only** and
> compiles **only the icons your app actually uses** into
> [`vector_graphics`](https://pub.dev/packages/vector_graphics) `.vec` assets.

[![Platforms](https://img.shields.io/badge/platforms-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-lightgrey)](#platforms)

## Preview

> Run the [example app](#example-app) to see every
> component in light and dark themes.

| Light | Dark |
|-------|------|
| _`docs/preview-light.png`_ | _`docs/preview-dark.png`_ |

## Features

- **Strict layering** — `tokens → theme → primitives → components`. No layer
  imports a layer above it.
- **Token-driven** — no inline colors, sizes, or text styles in components.
  Colors come from `context.sbColors`; everything else from `Sb*` token classes.
- **Native structure, Supabase skin** — components are built on Flutter's native
  building blocks for a real platform feel: `ListView`/`ListView.separated`
  (lists, tables), `PageView` (carousel), `IndexedStack` (tab panels — preserves
  state), `Overlay`/`OverlayPortal` + `SingleChildScrollView` (menus, scrollable
  sheets/modals), `Navigator` routes (modals/sheets), native `Image` with
  `errorBuilder`/`frameBuilder` (avatars), `GestureDetector`/`EditableText`
  (input) — while all visuals stay token-driven. No Material chrome or ink
  ripples: press/hover feedback is a Supabase-style background change via
  `SbInteraction`.
- **Const-first & low-overhead** — const constructors throughout, minimal widget
  depth, `RepaintBoundary` around animated surfaces, no reflection, no runtime
  style computation.
- **One `ThemeExtension`** — a single `SbTheme` drives light and dark; components
  react to theme changes instantly with no hardcoded colors.
- **Supabase's type stack, bundled** — CustomFont (Circular) for UI text
  (`--font-custom`, from `apps/studio/fonts`) and Source Code Pro for mono/code
  (`--font-source-code-pro`), shipped and wired into the theme; consumers get
  them automatically, no setup.
- **Lean icon pipeline** — the package ships icon *names* only; a CLI fetches and
  compiles just the icons you reference. Nothing unused is bundled.
- **Multi-platform** — Android, iOS, Web, macOS, Windows, Linux.

## Install

```yaml
dependencies:
  supabase_ui:
    git: https://github.com/udyan-dev/supabase_ui.git
  # Needed to render the icons compiled by build_icons:
  vector_graphics: ^1.2.2
```

The package **bundles CustomFont** (Supabase's Circular, the exact faces from
`apps/studio/fonts`) for UI text and **Source Code Pro** for mono/code, and
applies them through `SbAppTheme` — so text renders in Supabase's real typefaces
with no app-side font setup.

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:supabase_ui/supabase_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: SbAppTheme.light(),
        darkTheme: SbAppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SbButton(label: 'Get started', onPressed: () {}),
          ),
        ),
      );
}
```

## Theme

```dart
MaterialApp(
  theme: SbAppTheme.light(),
  darkTheme: SbAppTheme.dark(),
);
```

Access the active theme anywhere:

```dart
final colors = context.sbColors;  // resolved color roles
final isDark = context.sb.isDark;  // brightness
```

### Tokens

| Family       | Class           | Examples                                         |
|--------------|-----------------|--------------------------------------------------|
| Colors       | `SbColors`      | `brand` (#3ECF8E), `bgLight`/`bgDark`, `fgLight`/`fgDark`, `destructive`, `warning*` (exact Supabase token values) |
| Spacing      | `SbSpacing`     | `s4, s8, s12, s16, s20, s24, s32, s40, s48, s64` |
| Radius       | `SbRadius`      | `all4, all6, all8, all12, all16`, `full`         |
| Typography   | `SbTypography`  | `display, heading, title, body, caption, mono`   |
| Elevation    | `SbElevation`   | `e0…e4`                                          |
| Motion       | `SbMotion`      | `fast, normal, slow`, `standard` curve           |

> Color *roles* (background, surface, text, primary, …) live in
> `context.sbColors`; the raw `SbColors` palette is theme-internal.

## Primitives

- `SbText` — typed text (`SbTextVariant` + `SbColorRole`), e.g. `SbText.body('Hi')`.
- `SbBox` / `SbGap` — token-driven spacing and gaps.
- `SbSurface` — the one styled-container primitive (fill, border, radius, shadow, padding).
- `SbInteraction` — hover/focus/press/disabled state for any interactive widget.

## Components

`SbButton`, `SbTextField`, `SbTextArea`, `SbSelect`, `SbMultiSelect`,
`SbSearchField`, `SbCard`, `SbModal` (`showSbModal`), `SbSheet` (`showSbSheet`,
bottom sheet), `SbSideSheet` (`showSbSideSheet`), `SbDropdown` (menu, incl.
destructive items), `SbMenuBar`, `SbCheckbox`, `SbRadio`, `SbSwitch`, `SbSlider`,
`SbSegmentedControl`, `SbTooltip`, `SbBadge`, `SbChip`, `SbAvatar`, `SbDivider`,
`SbTabs`, `SbAccordion`, `SbCarousel`, `SbAlert`, `SbBanner`, `SbEmptyState`,
`SbTable`, `SbList`, `SbListTile`, `SbTreeView`, `SbBreadcrumb`, `SbPagination`,
`SbAppBar`, `SbBottomNav`, `SbFab`, `SbToast` (`showSbToast`), `SbSnackbar`
(`showSbSnackbar`), `SbProgress` / `SbCircularProgress`, `SbSkeleton` /
`SbSkeletonText`, `SbShimmer` / `SbShimmerBox`.

Animations match Supabase's own keyframes/easings (overlay & dropdown
`cubic-bezier(.16,1,.3,1)`, panels & sheets `cubic-bezier(.87,0,.13,1)`,
accordion `ease-out`, skeleton 2s pulse, spinner 1s linear).

```dart
SbButton(label: 'Save', onPressed: () {});
SbButton(label: 'Delete', variant: SbButtonVariant.destructive, onPressed: () {});
SbBadge('Active', variant: SbBadgeVariant.brand, dot: true);

// Loading states:
const SbCircularProgress();                 // spinner
const SbSkeleton(width: 120, height: 16);   // shimmer placeholder
const SbSkeletonText(lines: 3);             // multi-line text placeholder
```

Every interactive component supports **hover, focus, pressed, and disabled**
states via the shared `SbInteraction` primitive.

## Icons

The package ships **names only** — `SupabaseIcons` is auto-generated from the
full Lucide set (no assets bundled). You reference icons by name, then a CLI
fetches and compiles only those you use.

### 1. Reference icons by name

```dart
SupabaseIcons.search;      // 'search'
SupabaseIcons.userCircle;  // 'user-circle'
```

### 2. Build the assets

```sh
dart run supabase_ui:build_icons
```

This scans your `lib/` for `SupabaseIcons.*` usages, downloads each SVG from
Lucide, compiles it to `assets/supabase_icons/<name>.vec`, writes a typed
`lib/generated/supabase_icon_assets.dart`, and registers the asset directory in
your `pubspec.yaml`. Already-compiled icons are cached (use `--clean` to rebuild,
`--ref <git-ref>` to pin a Lucide version).

### 3. Render

```dart
import 'package:vector_graphics/vector_graphics.dart';
import 'generated/supabase_icon_assets.dart';

VectorGraphic(
  loader: AssetBytesLoader(SupabaseIconAssets.search),
  colorFilter: ColorFilter.mode(context.sbColors.textPrimary, BlendMode.srcIn),
);
```

> There is intentionally **no `SbIcon` widget** — render with `VectorGraphic`
> directly for zero indirection.

### Keeping icon names in sync

`.github/workflows/sync_lucide.yml` regenerates `SupabaseIcons` from upstream
Lucide weekly (and on demand) via `tool/generate_icon_names.dart`, committing
any changes.

## Example app

A runnable, multi-screen gallery lives in [`example/`](example/):

```
example/lib/
├── main.dart              # app shell + responsive navigation
├── theme_toggle.dart      # light/dark controller (InheritedWidget)
└── screens/
    ├── buttons_demo.dart      # variants, sizes, states, type scale
    ├── inputs_demo.dart       # text fields, textarea, select
    ├── components_demo.dart   # selection, data display, feedback, overlays, skeleton
    └── icons_demo.dart        # Lucide → .vec
```

```sh
cd example
flutter pub get
dart run supabase_ui:build_icons   # generate the demo icons
flutter run                        # any platform below
```

### Platforms

Android · iOS · Web · macOS · Windows · Linux.

## Architecture

```
tokens/       compile-time constants (color palette, spacing, radius, type, elevation, motion)
  ↓
theme/        SbTheme (ThemeExtension) — the single source of brightness-dependent color roles
  ↓
primitives/   SbText, SbBox/SbGap, SbSurface, SbInteraction — the only building blocks
  ↓
components/   SbButton, SbTextField, … — composed from primitives, never raw Flutter containers
```

- Brightness-independent tokens (spacing, radius, typography, elevation, motion)
  are `const` and referenced directly — no theme lookup overhead.
- Only **colors** vary by theme; they resolve through `context.sbColors`.
- Icons are decoupled entirely: names in the package, assets generated per app.

## Performance philosophy

- `const` constructors everywhere the analyzer allows.
- `StatelessWidget` by default; state only where interaction demands it.
- `RepaintBoundary` around self-animating surfaces (e.g. `SbSkeleton`).
- No inline styles, no runtime style computation, no reflection.
- Shallow widget trees and token reuse keep rebuilds cheap and bundle size small.

## Testing

```sh
flutter test                      # widget, theme, and golden tests
flutter test --update-goldens     # regenerate golden baselines after intended changes
```

Coverage includes per-component widget tests, theme/token tests, and golden
snapshots (`test/goldens/`) for buttons and badges in both themes.

## Contributing

1. Fork and branch from `main`.
2. Keep the layering rule intact — no upward imports, no inline styles.
3. `flutter analyze` must be clean and `flutter test` green (regenerate goldens
   only for intended visual changes).
4. Open a PR describing the change and its visual impact.

## License

See [LICENSE](LICENSE).
