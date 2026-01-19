# StormXP

**StormXP** is a lightweight, highly configurable standalone Experience, Reputation, and Honor bar for World of Warcraft. It provides a clean, modern alternative to the default Blizzard status bars, offering precise control over appearance, positioning, and data tracking.

## Key Features

### 🧠 Intelligent Tracking Modes
StormXP adapts to your gameplay needs. You can force a specific tracking mode or let the addon decide for you.

*   **Auto (Default):** The "Set and Forget" mode.
    *   **While Leveling:** Tracks your Experience and Quest progress.
    *   **At Max Level:** Automatically switches to tracking your **Watched Faction** (Reputation/Renown) or **Honor**, depending on your settings. If nothing is watched, the bar can auto-hide.
*   **Experience:** Forces the bar to track XP, even at max level.
*   **Reputation:** Forces the bar to track your currently watched Faction or Renown level.
*   **Honor:** Forces the bar to track your Honor Level and progress.

### 🎨 Positioning & Visuals
Customize the bar to fit your UI perfectly using two methods:

1.  **Drag & Drop:** Unlock the frame in the options to drag it anywhere on your screen.
2.  **Pixel-Perfect Precision:** Use the **X Offset** and **Y Offset** sliders in the configuration menu for exact positioning.

You also have full control over:
*   **Scale:** Resize the entire bar to match your UI scale.
*   **Alpha:** Adjust transparency/opacity.
*   **Textures:** Choose from any shared media status bar texture.
*   **Colors:** Customize colors for XP, Rested XP, Quest XP, Reputation, and Honor.

### 📊 Detailed Text Elements
StormXP features a modular text system. Each element can be independently toggled, positioned, and styled (Font, Size, Outline).

*   **Percentage:** Shows current progress percentage. Includes an optional **Quest XP** projection (e.g., `50% ( +10% )`).
*   **Value:** Shows raw numbers (e.g., `12,500 / 25,000`). Supports standard formatting (commas) or compact formatting (`12.5k`).
*   **Level/Rank:** Displays "Level 80", "Valdrakken Accord 15", or "Stormwind Exalted" depending on context.
*   **Session Stats:** Tracks your playtime, XP gained, and calculates **Time to Level (TTL)** based on your current pace. *Note: These hide automatically when not tracking XP.*

### 🖥️ Slash Commands
*   `/sxp` — Opens the configuration menu.
*   `/sxp reset` — Resets the current session statistics (Session Timer, XP Gained, XP/Hour).
