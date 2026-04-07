# 💎 SOVEREIGN V15 REVENUE INTEGRITY DNA

This document serves as the **IMMUTABLE STANDARD** for ad revenue distribution within the Sovereign Neo Ecosystem. This logic must NOT be broken, bypassed, or modified in any future updates or projects following this standard.

## 🎯 Core Directive

**"NO AD, NO REVENUE."**
Fiscal distribution is strictly gated by active visual verification of an advertisement.

## 🛠️ Technical Specifications

### 1. Home-Feed Gating (Client-Side)

- **Signal Restriction**: The `AD_IMPRESSION` WebSocket action is strictly bound to the Home Tab (`_currentIndex == 0`).
- **Tab-Aware Pause**: The `VideoPlayerController` for ads MUST be paused the millisecond a user navigates away from the Home feed.
- **Tab-Aware Resume**: Playback resumes ONLY when returning to the Home feed.

### 2. Double-Credit Prevention (Sentinels)

- **Credit Logic**: Each ad rotation (e.g., 15-second sequence) is credited exactly ONCE.
- **Sentinel Flag**: The `_isCurrentAdCredited` flag must be used to ensure that toggling between tabs does not trigger duplicate revenue for the same ad content.

### 3. Server-Side Fiscal Splits (A_105)

- **3-Layer Distribution**: Every verified impression triggers a real-time ledger update for three parties:
  - **Viewer**: Reward for attention.
  - **Creator (Uploader)**: Reward for content ownership.
  - **Platform (Admin)**: Operational share (Vault: `NODE_ALPHA`).
- **Dynamic Calibration**: Percentages are pulled in real-time from persistent `config.json` settings, controlled by the Admin Desk.

### 4. Moderation & Verification

- **A_120 Engine Sync**: Every impression must pass the AI Impression Engine check (`impression_engine.py`) to prevent bot-farming and synthetic revenue.
- **Persistence**: Platform/Creator/User share settings MUST persist across server restarts.

## 📜 Ethical Commitment

This setup is the foundation of the **Sovereign Creator Economy**. Any attempt to simulate revenue without ad visibility is a violation of the V15 Standard.

---
*Last Updated: 2026-01-31*
*Status: ENFORCED & IMMUTABLE*
