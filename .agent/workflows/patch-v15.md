---
description: Sovereign V15 Surgical Patch [Safe-Injection Protocol]
---

# Sovereign V15 Surgical Patch

Use this command when you need to **update, edit, or inject** a specific feature into the ecosystem without affecting any existing logic or breaking the 3-panel synchronization.

// turbo-all

## 1. TARGET LOCK [PRE-EDIT]

* **Locate**: Use `grep` to find the exact line range for the target feature.
* **Isolate**: Confirm the feature belongs to one of the 15 Sovereign Modules (A_101 - A_115).
* **Standard**: Verify the target file is `user_panel/lib/main.dart` or `admin_panel/lib/main.dart`.

## 2. SURGICAL INJECTION

* **Scope**: Edit ONLY the target widget or method.
* **Guard**: Do NOT modify `_onInteraction`, `WebSocketChannel`, or `SovereignGuard` logic unless explicitly requested.
* **Visuals**: Ensure `SovereignColors.cyan` and `glassmorphic` styling are maintained.

## 3. ZERO-BREAK VERIFICATION

* **Lint Check**: Immediately run a lint check on the saved file.
* **Hot Reload**: Press `r` in the terminal to verify the UI reflects the change.
* **Interaction Test**: Trigger the feature and verify the Admin Panel (Port 8080) receives a "SUCCESS" log in the **Interaction Engine**.

## 4. RESTORATION (IF BROKEN)

* **Rollback**: If the app shows a "White Screen" or Crashing logs, immediately revert the `multi_replace_file_content` chunk.

---
**[Sovereign V15 Patch - Zero Collision Standard]**
