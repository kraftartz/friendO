---
name: Celestial Cadence
colors:
  surface: '#141026'
  surface-dim: '#141026'
  surface-bright: '#3a364e'
  surface-container-lowest: '#0f0b21'
  surface-container-low: '#1c182f'
  surface-container: '#211c33'
  surface-container-high: '#2b273e'
  surface-container-highest: '#363249'
  on-surface: '#e6defd'
  on-surface-variant: '#cbc3d7'
  inverse-surface: '#e6defd'
  inverse-on-surface: '#322d45'
  outline: '#958ea0'
  outline-variant: '#494454'
  surface-tint: '#d0bcff'
  primary: '#d0bcff'
  on-primary: '#3c0091'
  primary-container: '#a078ff'
  on-primary-container: '#340080'
  inverse-primary: '#6d3bd7'
  secondary: '#ccbeff'
  on-secondary: '#332664'
  secondary-container: '#4a3d7c'
  on-secondary-container: '#baabf3'
  tertiary: '#7bd0ff'
  on-tertiary: '#00354a'
  tertiary-container: '#009bd1'
  on-tertiary-container: '#002d40'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#d0bcff'
  on-primary-fixed: '#23005c'
  on-primary-fixed-variant: '#5516be'
  secondary-fixed: '#e7deff'
  secondary-fixed-dim: '#ccbeff'
  on-secondary-fixed: '#1e0e4e'
  on-secondary-fixed-variant: '#4a3d7c'
  tertiary-fixed: '#c4e7ff'
  tertiary-fixed-dim: '#7bd0ff'
  on-tertiary-fixed: '#001e2c'
  on-tertiary-fixed-variant: '#004c69'
  background: '#141026'
  on-background: '#e6defd'
  surface-variant: '#363249'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.005em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: 0em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: 0.005em
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  space-2xs: 0.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-2xl: 3rem
  space-3xl: 4rem
  gutter-mobile: 1rem
  gutter-desktop: 1.5rem
  container-max: 72rem
---

## Brand & Style

This design system aims for an intimate, reflective mood, made for looking after friendships on a
repeating Cadence. It stays warm and thoughtful and avoids cold, analytical CRM mechanics. It
treats friendships as loops that come back around, not as transaction logs.

The visual direction merges **soft neumorphism** with layered depth. Deep night-violet fields give
a calm canvas where a logged Meeting feels warm and tangible. Surfaces do not float sharply or cast
aggressive drop shadows. They push gently out of the background, or sink into it, using light from
two directions and rich dark occlusion. Soft luminous accents mark Cadence states, how recently you
met, and how close a Friend sits. The overall feel is calm, tactile, and private.

## Colors

The palette stays in a rich dark space. It avoids pitch black in favour of chromatic night violets.

### Core Tonal Palette
- **Canvas Base (`#0d0b18`)**: The backdrop behind a full screen.
- **Surface Level 1 (`#141026`)**: The standard raised surface for containers, cards, and panels.
- **Surface Level 2 (`#1c1636`)**: Raised cards, interactive modules, and floating panels.
- **Surface Inset / Well (`#090711`)**: Debossed fields, input troughs, and Phase tracks.

### Lighting & Depth Pigments
- **Soft Specular Highlight (`#2b2252`)**: Top-left edge glow on a raised surface.
- **Ambient Occlusion Shadow (`#06050c`)**: Bottom-right shadow that gives a surface its mass.
- **Inner Rim Glow (`rgba(196, 181, 253, 0.08)`)**: Faint inner radiance on an active control.

### State & Cadence Accents
- **Electric Violet (`#8b5cf6`) & Radiant Purple (`#a855f7`)**: Primary actions and the active Orbit.
- **Luminous Lavender (`#c4b5fd`)**: Emphasised type, quiet icons, and Orbit tracks.
- **Fresh Aurora / Mint-Cyan (`#2dd4bf` to `#38bdf8`)**: A new Friend, and a recently logged Meeting.
- **Solar Amber (`#fbbf24`)**: An Overdue Friend, and anything asking for attention.
- **Dormant Nebula (`#e879f9`)**: Milestones, birthdays, and anniversaries.

## Typography

Plus Jakarta Sans is used for every role. Its geometric shapes stay readable for dates and lists,
while its open apertures and organic curves keep the tone warm.

- **Display & Headlines**: Negative letter spacing, medium to bold weight. Used for a Friend's name
  and for Cadence summaries.
- **Body Content**: Comfortable line height, for Notes, Topics, and Updates.
- **Labels & Micro-data**: Tighter and tracked out (`label-sm` at `0.05em`). Used on Phase meters,
  state indicators, and Orbit badges.

## Layout & Spacing

The layout keeps content centred and focused. It avoids the density of a corporate dashboard.

- **Mobile (< 768px)**: One column with `1rem` edge gutters. Modules stack vertically, and a swipe
  moves between Orbits.
- **Tablet (768px - 1024px)**: 8 columns with `1.5rem` gutters, balancing the Friends list against
  a docked Meeting history.
- **Desktop (> 1024px)**: 12 columns, capped at `72rem` (1152px) and centred. This keeps a Friend
  page reading like a personal journal rather than a data grid.
- **Spacing Scale**: An 8pt base grid (`0.5rem`, `1rem`, `1.5rem`, `2rem`). Soft shadows need room,
  so that convex and concave gradients do not collide.

## Elevation & Depth

Hierarchy comes from soft neumorphism plus a layered glow:

### 1. Convex Extruded (Standard Raised Surfaces)
Cards, primary buttons, and active tabs rise gently out of the `#0d0b18` base.
- **Light Source**: From the top left (`-4px -4px 12px rgba(43, 34, 82, 0.45)`).
- **Shadow Sink**: To the bottom right (`6px 6px 16px rgba(6, 5, 12, 0.85)`).
- **Surface Fill**: A subtle linear gradient (`135deg, #18132e 0%, #130f25 100%`).

### 2. Concave Debossed (Wells, Inputs & Tracks)
Note fields, search fields, and empty Orbit tracks sink into the surface behind them.
- **Inner Shadow Upper**: `inset 3px 3px 8px rgba(6, 5, 12, 0.9)`.
- **Inner Highlight Lower**: `inset -2px -2px 6px rgba(43, 34, 82, 0.25)`.
- **Surface Fill**: Flat `#090711`, or a subtle inverse gradient.

### 3. Luminescence (Active States)
Overdue warnings, primary actions, and the active Orbit add an ambient flare:
- A diffused outer violet aura: `0 0 24px rgba(139, 92, 246, 0.35)`.
- An amber Overdue warning emits: `0 0 20px rgba(251, 191, 36, 0.3)`.

## Shapes

The shape language favours high roundness and full pill contours, echoing the loops the Beads
travel.

- **Pill Contours (`roundedness: 3`)**: All primary buttons, state chips, filter selectors, and
  Affinity tags.
- **Containers & Note Modules**: Large radii (`rounded-2xl` / `1.5rem` to `rounded-3xl` / `2rem`),
  giving surfaces a smooth, river-stone feel.
- **Avatars & Beads**: Strictly circular, with a double halo that carries the Friend's Cadence.

## Components

### Buttons & Quick-Actions
- **Primary Pill**: Convex gradient (`#9061f9` to `#7c3aed`), glowing perimeter, white-to-lavender
  type. On press it flips to a debossed state with an inner glow.
- **Secondary Surface Button**: Dual-shadow convex violet surface (`#1c1636`) with `#c4b5fd` type
  and a faint `#2b2252` top-left rim.
- **Ghost/Tertiary**: No background, glowing text on hover, inside a soft pill border at 10%
  opacity.

### Friend Cards
- A convex card with a circular Avatar beside the Orbit tracks.
- A subtle inner gradient. The outer glow turns Solar Amber when the Friend is Overdue, and Aurora
  Cyan just after a Meeting is logged.
- A Phase rail: an inset debossed groove along the base of the card, filled by a soft glowing
  violet pill.

### Cadence Tags & Chips
- Fully rounded pills (`height: 28px` or `32px`).
- Inactive: a sunk debossed container with muted lavender text (`#948ab8`).
- Active: a raised pill with a luminous indicator. Cyan for a recent Meeting, Amber for Overdue,
  Purple for the Inner Orbit.

### Note Fields
- Deep debossed wells with dark occlusion at the top-left edge.
- A smooth borderless transition into the surface behind.
- Focus: a 1px inner trace of `#8b5cf6` with an ambient lavender radiance. Placeholder text sits in
  muted violet (`#5e5384`).

### The Dial (Product-Specific)
- A concentric, tactile graphic. Each Orbit holds the Friends whose Cadence falls in its range, for
  example weekly, fortnightly, monthly, or seasonal.
- A circular debossed trough per Orbit, carrying the Beads. One Bead is one Friend, and it travels
  its Orbit as the Phase grows.
