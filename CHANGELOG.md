# Changelog

## 0.1.0

Initial release — a token-driven Flutter design system matched to Supabase's
own design tokens and fonts.

### Design tokens (sourced from Supabase)
- **Colors** — exact resolved values from Supabase's compiled design-system CSS
  (default light + dark themes): backgrounds, surfaces, borders, foregrounds,
  brand `#3ECF8E`, `destructive` `#E54D2E`, `warning`.
- **Typography** — Supabase's Tailwind type scale (sizes + line-heights) over
  their real fonts.
- **Spacing**, **Radius** (`xs/sm/lg/xl` = 2/4/8/16 + intermediates),
  **Elevation**, **Motion** — durations and the exact cubic-bezier easings from
  their CSS (overlay `(.16,1,.3,1)`, panel `(.87,0,.13,1)`).

### Fonts (bundled from `apps/studio/fonts`)
- **CustomFont** (Circular) for UI text — the seven faces (Book 400, Medium 500,
  Bold 700, Black 800 + italics), transcoded from the repo's woff2 to TTF.
- **Source Code Pro** for monospace/code.

### Theme
- Single `ThemeExtension` (`SbTheme`); `SbAppTheme.light()/dark()`; ergonomic
  `context.sb` / `context.sbColors`.

### Primitives
- `SbText`, `SbBox`/`SbGap`, `SbSurface`, `SbInteraction`.

### Animations
- Durations and easings taken verbatim from Supabase's CSS keyframes: overlay &
  dropdown `cubic-bezier(.16,1,.3,1)`, panels & sheets `cubic-bezier(.87,0,.13,1)`,
  accordion `ease-out`, skeleton 2s opacity pulse `(.4,0,.6,1)`, spinner 1s linear.
  Modal uses `overlayContentShow` (fade + translateY −2%).

### Components (43)
- **Forms**: `SbButton`, `SbTextField`, `SbTextArea`, `SbSelect`,
  `SbMultiSelect`, `SbSearchField`, `SbCheckbox`, `SbRadio`, `SbSwitch`,
  `SbSlider`, `SbSegmentedControl`.
- **Surfaces & overlays**: `SbCard`, `SbModal` (`showSbModal`), `SbSheet`
  (`showSbSheet`, bottom sheet), `SbSideSheet` (`showSbSideSheet`), `SbDropdown`
  (menu, incl. destructive items), `SbMenuBar`, `SbTooltip`, `SbAccordion`.
- **Navigation & layout**: `SbAppBar`, `SbBottomNav`, `SbBreadcrumb`,
  `SbPagination`, `SbList`, `SbListTile`, `SbTreeView`, `SbFab`.
- **Feedback**: `SbAlert`, `SbBanner`, `SbEmptyState`, `SbToast` (`showSbToast`),
  `SbSnackbar` (`showSbSnackbar`), `SbProgress` / `SbCircularProgress`,
  `SbSkeleton` / `SbSkeletonText`, `SbShimmer` / `SbShimmerBox`.
- **Data display**: `SbBadge`, `SbChip`, `SbAvatar`, `SbDivider`, `SbTabs`,
  `SbTable`, `SbCarousel`.
- Semantic model matches Supabase exactly: brand / destructive / warning +
  neutral.

### Icons
- Auto-generated `SupabaseIcons` (names only), `build_icons` CLI (fetch +
  compile only used Lucide icons to `.vec`), and a GitHub workflow keeping icon
  names in sync with upstream Lucide.

### Example & tests
- Multi-screen example gallery (Android, iOS, web, macOS, Windows, Linux).
- Widget, theme, and golden tests.
