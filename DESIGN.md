# BAC Guide design system

## Purpose

BAC Guide is a focused study companion for Algerian Baccalaureate (BAC) students. The product should feel calm, credible, encouraging, and easy to use during high-pressure revision—not like a collection of unrelated utilities. Its interface is Arabic-first, mobile-first, and supports both light and dark appearance.

This document is the visual and interaction contract for new work. Prefer the patterns and tokens here over screen-local colors, typography, spacing, or button treatments.

## Product principles

1. **Study first.** Put the next useful action, deadline, or learning resource ahead of account, ads, and secondary controls.
2. **Clear under pressure.** Use short Arabic labels, generous spacing, predictable hierarchy, and visible feedback.
3. **One familiar system.** A calculator, a BAC document, and a quiz should look like parts of the same app.
4. **Respect attention and connectivity.** Keep motion purposeful, avoid disruptive monetisation, and make downloaded study content understandable offline.
5. **Arabic is a first-class language.** Default to RTL content direction and test all screens with real Arabic strings; do not treat Arabic as a translated afterthought.

## Brand and colour

The existing introduction uses violet `#845EC2` as its visual anchor. The system retains that friendly violet and shifts the actionable brand colour slightly toward magenta for clearer emphasis and a more contemporary identity.

### Core palette

| Token | Value | Use |
| --- | --- | --- |
| `brand.primary` | `#8B2CF5` | Primary actions, selected controls, focus, progress |
| `brand.primaryContainer` | `#EEDFFF` | Light-mode feature surfaces and selected rows |
| `brand.onPrimary` | `#FFFFFF` | Content on primary-filled controls |
| `brand.onPrimaryContainer` | `#30006B` | Content on primary containers |
| `brand.gradientStart` | `#845EC2` | Soft decorative gradient origin; preserves the current intro identity |
| `brand.gradientEnd` | `#D946EF` | Magenta gradient accent; use sparingly |
| `brand.gradientTint` | `#FBEAFF` | Light gradient fade and decorative backdrop |
| `accent.teal` | `#006E5A` | Positive/completed state; never use purple alone to communicate success |
| `accent.amber` | `#8A5300` | Caution or pending state |
| `status.error` | `#BA1A1A` | Error/destructive state |
| `status.info` | `#005FAF` | Informational state |

Use a subtle `#845EC2` → `#D946EF` gradient only for editorial moments: onboarding decoration, a hero panel, or progress celebration. It is not a default card or button fill. Primary buttons remain solid `brand.primary` for clarity and contrast.

### Light mode semantic colours

| Token | Value |
| --- | --- |
| `surface` | `#FFFBFF` |
| `surfaceContainer` | `#F6F0F8` |
| `surfaceContainerHigh` | `#EFE7F1` |
| `onSurface` | `#1D1B20` |
| `onSurfaceVariant` | `#49454F` |
| `outline` | `#79747E` |
| `outlineVariant` | `#CAC4D0` |

### Dark mode semantic colours

| Token | Value |
| --- | --- |
| `surface` | `#151218` |
| `surfaceContainer` | `#211D24` |
| `surfaceContainerHigh` | `#2B2630` |
| `onSurface` | `#E9E0E9` |
| `onSurfaceVariant` | `#CBC4D0` |
| `outline` | `#958D9A` |
| `outlineVariant` | `#49454F` |
| `primary` | `#D9B8FF` |
| `primaryContainer` | `#6817B5` |
| `onPrimaryContainer` | `#F4E8FF` |

Never hard-code `Colors.black`, `Colors.white`, grey borders, or a hex value in a feature widget. Read semantic values from `Theme.of(context).colorScheme` (and an app token extension where a Material role is not enough). This is essential for dark mode.

## Typography and Arabic layout

Use **Tajawal** as the application font; it is already bundled and provides a suitable Arabic-first voice. Noto Sans Arabic may be used only as a fallback for missing glyphs. Keep Arabic copy in `TextDirection.rtl`; inherit direction from the app rather than assigning `ltr` to Arabic widgets.

| Role | Size / line height | Weight | Typical use |
| --- | --- | --- | --- |
| Display | 32 / 40 | 700 | Onboarding title, exceptional empty state |
| Headline | 24 / 32 | 700 | Screen title, key card title |
| Title | 20 / 28 | 700 | Section or dialog title |
| Body | 16 / 24 | 400 | Explanations and list content |
| Label | 14 / 20 | 500 | Buttons, chips, supporting labels |
| Caption | 12 / 16 | 500 | Metadata, helper text |

Avoid all-caps styling and tight line heights. Arabic lines need enough vertical room for diacritics. Numbers and formulas may use left-to-right direction locally where that makes them more legible. Use logical `start`/`end` padding, alignment, and icons so the interface mirrors properly in RTL.

## Layout, elevation, and responsiveness

Use an 8 dp spacing grid: `4`, `8`, `12`, `16`, `24`, `32`, `40`, `48`. The standard screen horizontal inset is 16 dp; use 24 dp on wide layouts. Tap targets must be at least 48 × 48 dp.

| Element | Specification |
| --- | --- |
| Primary / secondary button | 52 dp height, 16 dp corner radius, full width when it is the page’s main action |
| Compact icon button | 48 dp target, 12 dp visible shape radius |
| Card | 16 dp radius, `surfaceContainer` fill, 0–1 dp tonal/elevation treatment, no heavy shadow |
| List row | Minimum 64 dp height, 16 dp horizontal padding, 12 dp gap between rows |
| Dialog / bottom sheet | 28 dp top radius, 24 dp content padding |
| Hero / countdown card | 24 dp radius, primary container or restrained brand gradient |

Use a single-column layout on phones. At widths of 600 dp and above, constrain readable content to approximately 720 dp and allow a two-column dashboard only when the content benefits from it. Do not stretch dense lists or Arabic paragraphs across the whole tablet width.

## Components and states

### Navigation

- Every feature screen has an RTL-aware top app bar: back action at logical start, clear Arabic title, and only necessary actions.
- The home screen should expose 3–5 primary destinations as clear study actions: BAC papers/resources, grade calculator, quiz/revision, and curriculum. Avoid developer or account-maintenance actions in the primary content area.
- Preserve state when moving between main destinations. Deep pages return to the exact prior context.

### Buttons

- Use `FilledButton` for one primary action per view; use `OutlinedButton` or `TextButton` for alternatives.
- Destructive actions use an error-coloured outlined or filled treatment only after confirmation.
- Buttons show loading inline and disable duplicate submission while work is running. Do not replace the whole screen with a spinner for a local action.
- The press-scale feedback may be used on prominent custom cards, but standard Material button state layers are sufficient for ordinary buttons.

### Forms, selectors, and feedback

- Subject and field selection uses full-width selectable rows with leading/trailing logical check controls, clear selected container colour, and semantic labels for screen readers.
- Inputs have persistent labels, helper text where needed, visible error text, and no colour-only validation.
- Use empty states that explain the situation and offer one next action. Use skeletons for page-level loading where content shape is known; use a centred progress indicator for a short, blocking initial load.
- Use snackbars for brief non-critical confirmation or recoverable failure; use dialogs only for decisions that need confirmation.

### Learning content

- Make the content type, academic stream, subject, year, and availability clear before opening a document.
- Distinguish “not downloaded”, “downloading”, “available offline”, “failed”, and “updated” with text and icons in addition to colour.
- Grade results should privilege the final grade, then show a transparent subject-by-subject breakdown and a clear edit action.
- Quizzes show one question at a time, progress such as `3 / 10`, immediate unambiguous answer feedback, and a concise final review.

## Motion and introduction flow

Motion should orient the student or confirm an action; it should never delay studying. Respect `MediaQuery.disableAnimations` / platform reduced-motion preferences and offer the final state without decorative animation when motion is disabled.

The current onboarding approach is broadly performance-safe: a 420 ms `SharedAxisTransition`, two static radial gradients, and the 120 ms button scale are inexpensive on modern devices. The Lottie asset is the main item worth measuring, especially on entry-level Android phones common in the target audience.

Implementation guardrails:

- Keep only the visible onboarding step alive. A `PageTransitionSwitcher` temporarily composes outgoing and incoming pages during its transition; do not preload several Lottie-heavy pages.
- Set the Lottie to a bounded size, avoid running it off-screen, and pause/dispose it when the route is inactive. Prefer a static fallback or reduced-motion variant for weak devices.
- Do not animate large blurs, full-screen opacity layers, or continuously repainting gradients. The current static `RadialGradient` decorations are acceptable.
- Make onboarding responsive with `SafeArea`, `SingleChildScrollView`, and constraints; the current fixed 350 dp illustration plus text/button column can overflow on small-height devices or when accessibility text is enlarged.
- Replace the temporary floating action buttons (swap/back) with explicit bottom actions: “متابعة” (continue) and “رجوع” (back), and do not let a selection step advance until a stream is selected.
- Profile in Flutter DevTools on a low-end physical Android device before adding more animation. Aim for no sustained raster/UI jank during transition and animation.

## Accessibility and quality bar

- Meet WCAG AA contrast for normal text and interactive elements (at least 4.5:1); verify actual final colour pairings rather than assuming a purple is readable.
- Support system text scaling without clipped copy, including onboarding, field selectors, dialogs, countdown units, and quiz answers.
- Give all meaningful icons accessible labels. Decorative illustrations and icons should be excluded from semantics.
- Do not convey selected, correct, downloaded, or error states by colour alone.
- Support light, dark, and system theme selection. Persist the user’s explicit theme choice.
- Keep font and asset loading predictable; test cold start with slow network and no network.

## Flutter implementation contract

1. Build the app theme from the tokens above with `ColorScheme` values for **both** brightnesses. `MaterialApp` must use those `theme` and `darkTheme` instances—not `ThemeData.dark()` or a separate seed-colour theme.
2. Set `locale`/localizations and `Directionality` so Arabic defaults to RTL application-wide. Use local overrides only for numbers/formulas or deliberately mixed content.
3. Centralise component themes (`FilledButtonThemeData`, `OutlinedButtonThemeData`, `CardThemeData`, `InputDecorationTheme`, `AppBarTheme`, `NavigationBarThemeData`) to encode size, radius, and typography once.
4. Refactor existing screens incrementally: replace hard-coded colours first, then apply component patterns, then refine layout. Do not redesign one screen with one-off tokens.
5. Add widget tests for light and dark rendering, RTL layout, 200% text scaling for key flows, and disabled/loading/selected/error component states.

## Definition of done for UI changes

A UI task is complete when it follows this document, works in light and dark mode, is usable in RTL with Arabic copy, has no overflow at common phone sizes or enlarged text, and exposes loading/error/empty states appropriate to its data source. Verify with `flutter analyze` and at least the relevant widget tests before considering the change ready.
