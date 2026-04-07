# Love Tok 15: Sovereign Ignition [V15 Chain-Reaction]

This workflow starts the backend sync engine and both Flutter panels (Admin & User) in the correct sequence, aligned with the **V15 15-Module Standard**.

// turbo-all

1. Start the Backend Sync Engine:
   `python -m uvicorn main:app --host 0.0.0.0 --port 5000` (Cwd: `c:/Users/Admin/shorts/backend`)

2. Start the Sovereign Admin Panel:
   `flutter run -d chrome --web-port 8080` (Cwd: `c:/Users/Admin/shorts/admin_panel`)

3. Start the Love Tok User Panel:
   `flutter run -d chrome --web-port 8181` (Cwd: `c:/Users/Admin/shorts/user_panel`)

4. Start the Quantum Impression Engine:
   `docker-compose up -d` (Cwd: `c:/Users/Admin/shorts/Sovereign_Impression_Engine`)

5. Start the Sovereign Revenue Control:
   `docker-compose up -d` (Cwd: `c:/Users/Admin/shorts/Sovereign_Revenue_Control`)

6. Start the Sovereign Sponsor System:
   `docker-compose up -d` (Cwd: `c:/Users/Admin/shorts/Sovereign_Sponsor_System`)

7. Start the Sovereign Sound Loop (A_108):
   `docker-compose up -d` (Cwd: `c:/Users/Admin/shorts/Sovereign_Sound_Loop`)

## System Calibration & Sync

1. Refresh AI Mesh & Ledger Logic:
   `// Restarts are handled manually via terminal for Main Apps`
   `docker-compose restart impression_engine revenue_vault sponsor_system sound_loop`

2. Verify A_117 Quantum Creator Suite:
   - Go to (+) Tab.
   - Verify Utility Sidebar (Flip, Flash, Speed, Filters, Beauty):
     - Tap 'Flip': Verify "CAMERA FLIPPED" snackbar.
     - Tap 'Timer': Verify bottom sheet opens with 3s/10s options.
     - Tap 'Speed': Verify visibility toggle of the speed bar.
     - Tap 'Filters': Verify bottom sheet opens with Cyan/Neon/Glass options.
     - Tap 'Beautify': Verify icon/label color change (Cyan = ON).
   - Verify Concentric Record Button (Hold to Record, Tap to Stop).
   - Verify Gallery Injection: Tap 'Upload', Authorize via Sovereign Guard, and verify the physical device gallery opens.
   - Verify Multi-Media Selection: Select multiple photos and videos simultaneously.
   - Verify Sound Logic:
     - Tap top-center 'Add sound' button.
     - Verify bottom sheet opens with loop options.
     - Select a sound and verify the label updates.
   - Verify Sound Deep-Link: Go to a video, tap the spinning Music Disk, then tap 'USE THIS SOUND'. Verify it redirects to the Creator (+) Tab.
   - Success: Post Hub opens with a dynamic "X items" (or "1 item") count and a high-fidelity thumbnail preview in the box.

3. Verify A_118 Quantum Post Hub:
   - Go to (+) Tab -> Record -> Post Hub.
   - Verify Selection Menus: Tap 'Add Location', 'Tag People', 'Who can watch', or 'Add sound' (Confirm bottom sheet opens).
   - Verify Toggle Logic: Tap 'Allow Comments' (Confirm text toggles ON/OFF).
   - Verify Draft Logic: Tap 'Drafts' and confirm snackbar + nav pop.
   - Backend Log: "A_118 POST HUB: SOVEREIGN_POST published with X items and selected sound".

4. Verify Sovereign Long-Press Hub [A_121]:
   - Go to Home Feed.
   - Long-press on any video.
   - Verify 9-module grid menu (Save, Favorites, Not Interested, Report, Duet, Stitch, Speed, Clear display, Captions).
   - Backend Log: "LONG_PRESS_HUB_OPENED".

5. Verify Quantum Sound Hub [A_122]:
   - In (+) Tab (Creator Suite) or Post Hub: Long-press on any 'Add Sound' selector.
   - Verify premium white-contrast Sound Hub opens.
   - Verify Reactive Elements: Tap Tabs (Hot/For You), Location Pills (Bangladesh/Global), and Bottom Nav (Sound/Volume). Confirm UI color changes.
   - Verify Volume Logic: Tap 'Volume' in bottom nav. Verify 'Original sound' and 'Added sound' sliders appear.
   - Verify Search: Tap Search icon and confirm high-fidelity search bar expands.
   - Select a sound and verify sync: "CREATOR_SOUND_HUB_SELECT".

6. Verify Global Search Hub [A_123]:
   - Go to Discover Tab.
   - Enter a query in the Unified Search Bar.
   - Tap the 'Search' button.
   - Verify Floating Snackbar and Backend Log: "GLOBAL_SEARCH_QUERY".

7. Verify Sovereign Inbox Hub [A_124]:
   - Go to Inbox Tab.
   - Verify DM Logic: Tap Send icon (top right). Verify Direct Messages view opens with back-navigation.
     - Tap on a user to open Chat.
     - Verify High-Fidelity Messages: Sent (Cyan) and Received (Grey) bubbles displayed.
     - Verify Input Bar: Rounded pill with emoji icon.
     - Verify Send Logic: Enter text, verify Send arrow turns Cyan, and tap to sync: "DM_MESSAGE_SENT".
   - Verify Category Logic: Tap Followers, Likes, Comments, or Mentions. Verify view filters activities and shows back button.
   - Verify Follow Logic: Tap 'Follow' on a follower activity. Verify it toggles to 'Friends' (Sovereign Sync).
   - Verify Comment Interaction: On a "commented" activity:
     - Tap 'Reply': Verify reactive bottom sheet with text field opens. Enter text and Tap 'Send' to verify mesh sync.
     - Tap 'Like': Verify text color toggles to Cyan (High-Fidelity Feedback).
   - Verify Watch Logic: Tap 'Watch' on any activity. Verify it navigates back to Home feed.
   - Tap any activity and verify sync: "INBOX_ACTIVITY_OPEN".

8. Verify A_110 Interaction Log Sync:
   - Open Sovereign Admin Panel (Port 8080) -> A_110: INTERACTION LOGS.
   - Perform actions in User Panel:
     - Send a DM (from DM view).
     - Reply to a comment (from Inbox).
     - Like a comment (from Inbox).
   - Verify real-time JSON sync in the Admin 'LIVE INTERACTION STREAM':
     - "DM_MESSAGE_SENT"
     - "INBOX_COMMENT_REPLY_SUBMIT"
     - "INBOX_COMMENT_LIKE"
   - Success: Metadata is logged with <30ms latency.

9. Verify Creator Profile Hub [A_125]:
    - From the Feeds: Tap a creator's avatar.
    - Verify 5-Tab DNA: Swipe through the 5 tabs (Grid, Repost, Private, Saved, Hearts).
    - Follow Interaction: Tap 'Follow' and verify the button turns grey 'Following'.
    - Verify Options Hub [A_128]: Tap the '...' menu and verify Share/Report/Block functionality.
    - Backend Log: "PROFILE_FOLLOW_TOGGLE", "OPEN_CREATOR_OPTIONS", "OPEN_CREATOR_PROFILE".

10. Verify Follow Suggestions Hub [A_127]:
    - On the Creator Profile: Tap the down-arrow button (next to 'Message').
    - Verify UI Expansion: The keyboard arrow rotates 180° and the "Suggested accounts" tray slides into view.
    - Verify Glassmorphic Cards: Horizontal list of users appears with 'Follow' buttons and 'X' close buttons.
    - Verify Follow Toggle: Tap 'Follow' on a suggested card. Verify it instantly switches to 'Following' (White/Grey) and logs: "SUGGESTION_FOLLOW_TOGGLE".
    - Verify Close Logic: Tap 'X' on a card. Verify the card is removed from the list and logs: "SUGGESTION_CLOSE".
    - Verify 'See all' Hub: Tap 'See all'. Verify the glassmorphic bottom sheet slides up with the full list of suggested creators.
    - Verify Hub Interaction: Follow/Remove a user within the bottom sheet and verify it reflects in the profile tray instantly.
    - Verify Tray Removal: Tap the up-arrow to collapse the tray.
    - Backend Log: "PROFILE_SUGGESTIONS_TOGGLE".

11. Verify Global V-Mesh Comments [A_122]:
    - On any video: Send a comment. Scroll to next video and back.
    - Verify Persistence: Re-open comments; your comment MUST still be at the top [Branding: A_122].
    - Verify Nested Replies: Tap 'Reply' on a node, type a message, and Send.
    - Expand Node: Tap "View replies" and verify your reply is injected into the nested mesh instantly.
    - Verify Interaction: Toggle likes and emoji additions within the mesh.
    - Backend Log: "COMMENT_SENT", "COMMENT_LIKE_TOGGLE", "EXPAND_REPLIES", "EMOJI_ADD".

12. Verify Saved Hub [A_122]:
    - On Profile: Tap the Bookmark (Saved) tab.
    - Verify Sub-Navigation: Confirm high-fidelity sub-tabs "Videos" and "Sounds" appear with cyan indicator.
    - Verify Content: Toggle between "Videos" (Mesh Node Grid) and "Sounds" (Glassmorphic Audio List).
    - Sidebar Sync: Go to Home tab, tap "Saved" in the sidebar. Return to Profile and verify the video count incremented in the Saved-Videos mesh.
    - Backend Log: "SAVE", "UNSAVE", "OPEN_SAVED_HUB".

13. Verify Sound Detail Hub [A_108]:
    - From the Feeds: Tap the spinning music disk or the scrolling music marquee.
    - Verify Header DNA: Confirm cover art, sound title, and usage metrics (1.2M Videos).
    - Verify Save Interaction: Tap 'Add to Favorites'. Confirm toggle to 'In Favorites' with cyan border.
    - Verify Video Mesh: Swipe through the grid of videos using this sound.
    - Creator Integration: Tap 'USE THIS SOUND' and verify navigation to the Creator Suite [A_117].
    - Backend Log: "OPEN_SOUND_DETAIL", "SOUND_SAVED", "USE_SOUND_TRIGGERED".

- **100% TikTok Social DNA**: User Panel features Home feed (Long-press Options, Reactive states, Pull-to-refresh, Save/Favorites, High-Fidelity Player: 9:16 Full-Screen `BoxFit.cover`, play/pause overlays & animated hearts, **A_111 AI-Injecting 6-Network Native Ad Engine [VERIFIED: STABLE]**), **A_120 AI Impression Engine [VERIFIED: STABLE]**, **A_105 Sovereign Revenue Control [VERIFIED: STABLE]**, Discover (Trending Depth), **(+) Quantum Creator Suite [A_117] [VERIFIED: STABLE]: Multispeed Recording (0.3x-3x), Glassmorphic Utility Sidebar (Filters, Beautify, Timer), Multi-Media Gallery Injection (Photos/Videos/Multiple), and Interactive Recording HUD; leading to the Quantum Post Hub [A_118] [VERIFIED: STABLE] (High-Fidelity Metadata Orchestration: Location, Tagging, and Social Governance Toggles: Who can watch, Allow Comments, Allow Duet/Stitch; synced to V15 Central Mesh)**, **Comment Impression Logic [VERIFIED: STABLE] (Recursive Reply Orchestration with @user input targeting)**, **DM Portal [A_126] [VERIFIED: STABLE] (Reactive Message Clouds, Pill-Shaped Input, and sub-50ms Mesh Sync)**, **Creator Profile Hub [A_125] [VERIFIED: STABLE] (TikTok-Standard Stats, Multi-Tab Content Grid, and Reactive Follow state)**, **Follow Suggestions Hub [A_127] [VERIFIED: STABLE] (Horizontal Tray Orchestration with Glassmorphic Suggestion Cards)**, and Profile (**Edit Profile with Photo Harvesting [A_117]**, Settings Menu: AI-Moderated Quantum Wallet [A_113], MLM Network, Verification, Permission Center).
- **Deep-Link Navigation [VERIFIED: STABLE]**: Avatars link to creator profiles, and Music Disks/Marquees link to Sound Detail pages (coupled to **A_108 Sound Master**).
- **Administrative Status**: **Maintenance Mode** is a global blocker on the **Home tab**. **Quantum Wallet [A_113]** features bi-directional sync: User Panel shows **Separate Asset** balances (USD, BDT, COINS) with precise plus/minus exchange logic, allows both Deposit and Withdrawal requests (governed by an Admin-defined **Minimum Withdraw Limit** and **Strict Balance Validation**), and includes an **Exchange Room** for USD <-> Coin swaps (enforced by **Insufficient Balance** guardrails); Admin Panel features dual-ledger management, multi-gateway 'Edit & Save', 3-layer AI moderation, an **Exchange Protocol** to control platform commission (0-100%), **Base Coin Rate**, and the mandatory **Withdrawal Floor**, the **A_112 Smart Filter [VERIFIED: STABLE] (Real-time Keyword Registry, Shadow-Ban protocols, and AI Moderation Sensitivity orchestration)**, and the **MLM Protocol [A_107] [VERIFIED: STABLE]** which governs 'Onetime Activation' and 'Lifetime Recurring' network yields. **The Automated AI Commission System [A/B Logic]** ensures when User B (candidate) withdraws USD/BDT, a percentage of the yield is automatically cut and credited to User A (referrer) using the **Dr. Cr. Method**, secured by **AI Moderation [A_115]**. **Coin Rate** and **System Messages** are located on the **Profile tab** to ensure a clean video experience.
- **Precision Control**: Coin Rates are locked to `toStringAsFixed(1)` precision.
- **High-Fidelity Interaction**: Every interaction (Gift, Share, Follow, Recording) must preserve the sub-50ms sync latency with the Admin Panel.
- **Glassmorphism DNA**: All new UI modules must strictly follow the dark-neon aesthetic with `#00FFFF` accents.
- **A_106 Sovereign Law & Legal Evidence Module [VERIFIED: STABLE]**: Features the **Iron-Clad Universal Constitution**, Gavel-Protocol Gating, **Date of Birth selection with Auto-Calendar**, and **Full-Spectrum Permission Center** with **IRREFUTABLE Legal Archiving** where every consent and permission toggle is logged with User ID, IP, and Timestamp as digital evidence.
- **A_121 Sovereign Stealth Patch [VERIFIED: STABLE]**: Injects the **Stealth Boost Logic** where active interactions (Watch, Like, Comment, Share) on the platform dynamically increase the **Visibility Weight** of the user's own content, rewarding synergy with exponential reach.

- **A_122 Recursive Replies [VERIFIED: STABLE]**: Features real-time comment submission via keyboard and icon, dynamic '@user' targeting via 'Reply' tap, and A_112 Smart Filter sanitation.

## [CORE PROTOCOL] Structural Integrity

> [!IMPORTANT]
> **NO-BREAK POLICY**: All future updates must preserve the **V15 Chain-Reaction** standard.
>
> 1. **Zero Regression**: Real-time sync latency must remain sub-50ms.
> 2. **Module Stability**: None of the 15 Sovereign modules (A_101 to A_115) can be removed or functionally degraded.
> 3. **Sync Engine Priority**: The Backend WebSocket (Quantum Engine) is the immutable source of truth.
> 4. **Visual Fidelity**: TikTok Social DNA (Home feed logic, deep-linking) must not be compromised by administrative updates.
> 5. **Permission Enforcement**: All sensitive operations (Recording, Uploading, Wallet Transactions) MUST be guarded by `SovereignGuard` to ensure active permission authorization.
> 6. **Stealth Reach**: Content reach must be dynamic, directly influenced by the interaction-to-boost ratio of the Sovereign Stealth Patch.
