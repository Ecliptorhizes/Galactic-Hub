# Galactic-Hub

I programmed this project for someone, a game called **Galactic**, but it is now **discontinued**. I was never given credit for my work, and the owner of the game micromanaged the development. The repository is now public for reference and learning.

**Repository:** https://github.com/Ecliptorhizes/Galactic-Hub

---

## Overview

Galactic-Hub is a Roblox multi-place game framework built with [Knit](https://github.com/Sleitnick/Knit), [Rojo](https://rojo.space/), and [Wally](https://github.com/UpliftGames/wally). It features a central Hub where players choose destinations (Coruscant, ILUM) via Quick Play or Select Server, with place-specific loading screens and modular scripts that load only for the current place.

---

## Project Structure

```
src/
├── client/                    # Client-side (StarterPlayerScripts)
│   ├── Client.client.luau      # Entry point, loading screen, place-based controller loading
│   └── controllers/
│       ├── HubController.luau     # Main menu, Quick Play, Select Server, hover effects
│       ├── IlumController.luau    # ILUM place-specific logic (placeholder)
│       ├── CoruscantController.luau # Coruscant place-specific logic (placeholder)
│       └── CombatController.luau  # Lightsaber equip/ignite (keybinds 1, Q)
├── server/                    # Server-side (ServerScriptService)
│   ├── Server.server.luau     # Entry point, place-based service loading
│   └── services/
│       ├── Hub/HubService.luau      # Quick Play teleport to Coruscant/ILUM
│       ├── Ilum/IlumService.luau     # ILUM place-specific (placeholder)
│       ├── Coruscant/CoruscantService.luau # Coruscant place-specific (placeholder)
│       └── Combat/CombatService.luau # Lightsaber equip/ignite state
└── shared/
    └── modules/
        ├── Hub/Config.luau     # GameId, PlaceIds, HubPlaceIds, IlumEnabled, PlaceDisplayNames
        └── Combat/Config.luau  # Keybinds (1, Q), Animation IDs
```

---

## Script Explanations

### Client.client.luau

The client entry point. Runs on every place (Hub, ILUM, Coruscant).

- **Loading screen:** Shows `LoadingScreen`, hides `MainUi` (if present). Animates `loadingBar` from 0.001 to 1.003 scale and updates `LoadingNumber` text ("Loading (0/100)" → "Loading (100/100)").
- **UI path resolution:** Finds `loadingBar` and `LoadingNumber` under `Background.Dark.Holder` or `Background.Dark` (supports both Hub and ILUM GUI layouts).
- **Place detection:** Uses `game.PlaceId` and `HubConfig` to determine if the player is in Hub, ILUM, or Coruscant.
- **Controller loading:** Loads only the controller for the current place:
  - **Hub** → HubController
  - **ILUM** → IlumController (or CombatController fallback)
  - **Coruscant** → CoruscantController (or CombatController fallback)
- **Knit.Start():** Starts Knit after controllers are required. Waits for character, then hides loading screen and shows MainUi (if it exists).

---

### HubController.luau

Runs only in the Hub place. Handles the main menu.

- **Quick Play:** Finds map cards (Coruscant, ILUM) and wires up Quick Play buttons. On click, fires `HubService.RequestQuickPlay:Fire(placeKey)` to teleport the player.
- **Hover effects:** Uses TweenService to animate `BackgroundTransparency` and `TextColor3` on mouse enter/leave for Quick Play and Select Server buttons.
- **Button lookup:** Supports `ButtonQuickPlay`, `Button`, `ILUM-QUICKPLAY`, or first TextButton/ImageButton in the QuickPlay container.
- **Top bar hiding:** Optionally hides UI elements containing "PLANET:", "PLAYERS:", "SELECT SERVER" when `HideTopBarInHub` is true in config.
- **IlumEnabled:** Hides the ILUM map card and blocks Quick Play if `HubConfig.IlumEnabled` is false.

---

### HubService.luau

Runs only in the Hub place. Handles teleportation.

- **RequestQuickPlay:** Listens for client `RequestQuickPlay:Fire(placeKey)`. Validates `placeKey` ("Coruscant" or "Ilum"), checks `IlumEnabled` for ILUM, then calls `TeleportService:TeleportAsync(placeId, { player })`.
- **TeleportFailed:** Fires to the client if teleport fails (e.g. Studio, invalid place, config error).

---

### CombatController.luau

Runs in ILUM and Coruscant (combat places). Handles lightsaber input.

- **Keybinds:** `1` = equip saber, `Q` = ignite saber (from Combat Config).
- **Server requests:** Fires `CombatService.Server.EquipRequest:Fire()` and `IgniteRequest:Fire()`.
- **Listeners:** Subscribes to `EquipChanged` and `IgniteChanged` to update visuals (animations, blade visibility). Stub implementations for `PlayEquipAnimation` and `UpdateSaberVisual`.

---

### CombatService.luau

Runs in ILUM and Coruscant. Manages lightsaber state.

- **Player state:** Tracks `{ equipped, ignited }` per player.
- **EquipRequest:** Sets `equipped = true`, resets `ignited` on unequip, broadcasts `EquipChanged` to all clients.
- **IgniteRequest:** Sets `ignited = true/false` only if equipped, broadcasts `IgniteChanged` to all clients.

---

### IlumController.luau / IlumService.luau

Placeholder modules for ILUM-specific logic (e.g. crystal gathering). Loaded only when the player is in the ILUM place.

---

### CoruscantController.luau / CoruscantService.luau

Placeholder modules for Coruscant-specific logic (e.g. Jedi Temple). Loaded only when the player is in the Coruscant place.

---

### Hub/Config.luau

Central configuration:

- **GameId:** 6808056680
- **HubPlaceIds:** [6808056680, 98619119037493] (main Hub and Studio variant)
- **PlaceIds:** Hub, Coruscant (94260201585792), Ilum (81500806921573)
- **PlaceDisplayNames:** Display names for loading screen Location label
- **IlumEnabled:** Toggles ILUM Quick Play availability
- **HideTopBarInHub:** Toggles top bar hiding in the Hub

---

### Combat/Config.luau

- **Keybinds:** EquipSaber = One, IgniteSaber = Q
- **Animations:** Placeholder IDs for equip, unequip, idle holding

---

## Server.server.luau

The server entry point. Loads services based on place:

- **Hub** → Hub services
- **ILUM** → Ilum services (or Combat fallback)
- **Coruscant** → Coruscant services (or Combat fallback)

---

## Setup

1. **Rojo:** Sync this project to Roblox Studio via Rojo.
2. **Wally:** Run `wally install` to fetch Knit, Promise, Janitor, Trove.
3. **StarterGui:** Each place needs a `LoadingScreen` ScreenGui with `Background.Dark.Holder.barHolder.loadingBar` and `LoadingNumber` (under Holder or Dark). The Hub also needs `MainUi` with map cards and Quick Play/Select Server buttons.

---

## Dependencies

- [Knit](https://github.com/Sleitnick/Knit) – Game framework
- [Promise](https://github.com/evaera/Crochet) – Async utilities
- [Janitor](https://github.com/howmanysmall/Janitor) – Cleanup
- [Trove](https://github.com/Sleitnick/Trove) – Lifecycle management

---

*This project is discontinued. Use at your own discretion.*
