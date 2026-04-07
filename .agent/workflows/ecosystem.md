---
description: Sovereign V15 Ecosystem Command [Full System Orchestration]
---

# Sovereign V15 Ecosystem Orchestration

// turbo-all

This is the definitive guide and automated workflow for the **Sovereign Neo V15 Ecosystem**. It governs the launch, sync, and feature-integrity of the 3-panel architecture.

## I. MISSION CRITICAL LAUNCH SEQUENCE

1. **Start Quantum Sync Engine (Backend):**
   `python -m uvicorn main:app --host 0.0.0.0 --port 5000` (Cwd: `c:/Users/Admin/shorts/backend`)

2. **Ignite Dockerized Core Modules:**
   `docker-compose up -d` (Cwd: `c:/Users/Admin/shorts/Sovereign_Impression_Engine`)
   `docker-compose up -d` (Cwd: `c:/Users/Admin/shorts/Sovereign_Revenue_Control`)
   `docker-compose up -d` (Cwd: `c:/Users/Admin/shorts/Sovereign_Sponsor_System`)
   `docker-compose up -d` (Cwd: `c:/Users/Admin/shorts/Sovereign_Sound_Loop`)

3. **Launch Sovereign Admin Panel (God-Mode):**
   `flutter run -d chrome --web-port 8080` (Cwd: `c:/Users/Admin/shorts/admin_panel`)

4. **Launch Love Tok User Panel (V15 Client):**
   `flutter run -d chrome --web-port 8181` (Cwd: `c:/Users/Admin/shorts/user_panel`)

## II. SOVEREIGN MODULE REGISTRY [V15 STANDARD]

| Module | Name | Purpose | Status |
| :--- | :--- | :--- | :--- |
| **A_105** | Revenue Control | Manages wallet sync, USD/BDT/COIN exchange and split logic. | ONLINE |
| **A_107** | MLM Protocol | Governs referral network, lifetime yields, and node ID mapping. | ONLINE |
| **A_108** | Sound Master | High-fidelity audio loops, spinning music disks, and detail pages. | ONLINE |
| **A_109** | Global Omni-Sync | Real-time state broadcasting between Admin and User panels. | ONLINE |
| **A_110** | Interaction Log | Sub-30ms logging of likes, comments, shares, and metadata. | ONLINE |
| **A_111** | AI Ad Engine | 6-Network ad injection into video feed with stealth logic. | ONLINE |
| **A_113** | Quantum Wallet | Precise exchange room with logic-locked balance validation. | ONLINE |
| **A_117** | Creator Suite | Multi-speed recording, beast-mode filters, and media injection. | ONLINE |
| **A_121** | Stealth Hub | Conditional visibility boosting based on interaction ratios. | ONLINE |
| **A_125** | Profile Hub | 5-tab grid architecture with TikTok-standard stats. | ONLINE |

## III. CORE SYSTEM LOGIC & UPDATES

### 1. The Sovereign Options Hub (Workable TikTok Logic)

* **Access**: Available via the 'More' (3-dot) menu in Detail Feeds.
* **Features**:
  * **Analytics**: Real-time video performance stats and audience territory bars.
  * **Privacy**: Instant toggle between Everyone/Friends/Only Me.
  * **Social Send**: Direct simulated mesh-send to Node_X, Core, or Pulse.
* **Update Policy**: Hidden on the **Main Home Feed** to preserve a clean viewer experience, but active in all detail views.

### 2. Ad Targeting & Media Selection (A_111)

* **Logic**: Allows administrators/users to select promo media directly from their **Sovereign Profile Grid**.
* **Visuals**: Matches Profile DNA (0.75 ratio, view counts, cyan high-fidelity highlights).

### 3. Global Sync Latency

* **Requirement**: All interactions (Likes, Comments, Gifts) MUST reflect in the Admin Panel's **Interaction Streams** in <50ms.
* **Communication**: Persistent WebSockets via `sync_bridge_service`.

## IV. MAINTENANCE & CALIBRATION

1. **System Refresh**:
   `docker-compose restart` (Run in all Docker directories to clear cache).
   `flutter clean && flutter run` (If UI sync feels sluggish).

2. **Legal Guard (A_106)**:
   Mandatory DOB selection and Constitutional Gating must be active on every fresh install/session.

---
**[Sovereign Ecosystem V15 - Chain Reaction Standard]**
