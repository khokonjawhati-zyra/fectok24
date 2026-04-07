---
description: Sovereign Ecosystem Evolution [Update & Feature Injection Protocol]
---

# Sovereign V15 Evolution Protocol

This workflow provides the rules and commands for **modifying, updating, or injecting new features** into the Sovereign Neo Ecosystem while maintaining the V15 15-Module Standard.

## I. FEATURE DISCOVERY [WHERE TO EDIT]

To update a specific system, locate the following logic hubs in `user_panel/lib/main.dart`:

* **Video Feed UI**: Search for `VideoFeedItem` class.
* **Options Hub (TikTok Logic)**: Search for `_showOptionsHub()` and `_showSimulatedAnalytics()`.
* **Media Selection (Ad Targeting)**: Search for `_showMediaPicker()` inside `_SponsoredTemplatesViewState`.
* **Global Layout/Nav**: Search for `MainNavigation` class.
* **Real-Time Sync**: Search for `_onInteraction()` to see how data flows to the Admin Panel.

## II. UPDATE SAFETY RULES [ZERO REGRESSION]

1. **Preserve Module IDs**: Always comment new logic with the associated module ID (e.g., `// A_111 Update`).
2. **Maintain Latency**: Never use blocking synchronous calls (like large file reads) on the main UI thread. Keep sync <50ms.
3. **TikTok DNA**: All vertical content must use `BoxFit.cover` and `0.75` aspect ratio grid items.
4. **Sovereign Branding**: Use `SovereignColors.cyan` (#00FFFF) for all active states and highlights.

## III. HOT RELOAD & SYNC VERIFICATION

After editing the code, follow this sequence to verify the update:

1. **Hot Reload User Panel**:
    * Focus the Flutter terminal and press `r`.
    * If UI state is corrupted, press `R` (Full Restart).

2. **Verify Admin Stream**:
    * Open [http://localhost:8080/](http://localhost:8080/).
    * Go to **A_110 Interaction Logs**.
    * Trigger your new feature in the User Panel and confirm the JSON log appears instantly.

3. **Ecosystem Snapshot**:
    `docker-compose logs --tail=20 -f` (Run in module directories to check for backend errors).

## IV. FREQUENT UPDATE COMMANDS

* **To Hide UI Elements**: Use the `isHome` or similar conditional flags in `VideoFeedItem`.
* **To Add a Bottom Sheet**: Use `showModalBottomSheet()` with `Colors.transparent` and a glassmorphic container for the premium look.
* **To Inject Logic**: Use `widget.onInteraction('ACTION_NAME')` to ensure the Admin Panel stays in control.

---
**[Sovereign Evolution - Continuous Mesh Upgrade]**
