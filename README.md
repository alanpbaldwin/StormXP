# StormXP

**StormXP** is a lightweight, highly configurable standalone Experience, Reputation, and Honor bar for World of Warcraft (Retail 12.0+). It provides a clean, modern alternative to the default Blizzard status bars, offering precise control over appearance, positioning, and data tracking.

## Installation

Extract the `StormXP` folder into your `World of Warcraft/_retail_/Interface/AddOns/` directory and restart the game or `/reload`.

## Key Features

### Intelligent Tracking Modes
*   **Auto (Default):** Tracks XP while leveling, then switches to Reputation/Renown or Honor at max level. Can auto-hide when nothing is tracked.
*   **Experience / Reputation / Honor:** Force a specific tracking mode at any time.

### Positioning & Visuals
*   **Drag & Drop** or use **X/Y Offset** sliders for pixel-perfect positioning.
*   **Scale, Alpha, Frame Strata** — full control over size, transparency, and draw layer.
*   **Textures & Colors** — choose from any LibSharedMedia status bar texture. Customize colors for XP, Rested XP, Completed Quest XP, Reputation, Honor, and background.
*   **Segment Markers** — configurable minor and major percentage markers across the bar.

### Text Elements
Each text element can be independently toggled, positioned, and styled (Font, Size, Outline, Color).

*   **Percentage** — current progress, with optional completed quest XP projection (e.g., `50.0% (10.0%)`).
*   **Value** — raw numbers (`12,500 / 25,000`) with configurable separator or compact format (`12.5K`).
*   **Level/Rank** — displays level, faction standing, renown rank, or honor level.
*   **Rested %** — shows rested XP percentage with split bar/text coloring.
*   **Session Time, Level Time, Time to Level** — live session stats with customizable labels. Auto-hide when not tracking XP.

### Integration
*   **Minimap Icon** — toggle via settings. Left-click to enable/disable, right-click to open config.
*   **Addon Compartment** — appears in the addon list dropdown on the minimap.
*   **LibDataBroker** — data source for broker display addons (Titan Panel, Bazooka, etc.).
*   **Profiles** — full AceDB profile support with per-character overrides.

### Slash Commands
*   `/sxp` or `/stormxp` — Opens the configuration menu.
*   `/sxp reset` — Resets session statistics.
