# 🚨 SOVEREIGN V15: STABILITY & DATA PROTECTION REMINDER 🚨

This document serves as a **STRICT PROTOCOL** for all future updates and maintenance on the Sovereign Ecosystem. Any agent or developer working on this codebase MUST ensure the following systems remain 100% functional and no existing data is lost.

---

## 1. Deployment Systems 🚀

- **Domain Deployment (fectok.com)**: Updates MUST be deployed to the production domain and verified for SSL/CORS consistency.
- **IP Deployment (167.71.193.34)**: The IP version must always serve the latest stable build. Use `cache_bust.py` to ensure fresh delivery.
- **NEVER** overwrite configuration files (Nginx, Docker) without creating a backup first.

## 2. Identity & Verification 🛡️

- **Verification System (Blue Tick)**: The "Triple-Shield" logic (is_verified, isVerified, isVerifiedUser) in `main.py` and `main.dart` must be preserved. Hardcoded overrides for `@SOV_37108` and `@SOV_57015` are mandatory fail-safes.
- **Auth System (Recover Pulse)**: Login, Registration, and Password Recovery (Pulse Recovery) must never be broken. Test the websocket handshake (`/ws/user`) after every update.
- **Edit Profile**: Profile metadata (Name, Bio, Pic) sync via `CREATOR_STATS_SYNC` must remain intact.

## 3. Media & Storage ☁️

- **Cloudflare Storage System**: R2/S3 integration for media hosting must never be disconnected or corrupted.
- **Video Upload**: The upload bridge (Uplink Hub) and path-mapping for avatars and videos must remain functional.
- **Play System**: The HLS streaming player and media ledger synchronization must be verified across all devices.

## 4. Data Integrity 💽

- **NEVER** delete or format the `users_manifest.json` or `media_vault.json` files.
- **NEVER** clear Docker volumes without explicit user permission.
- **NEVER** modify database schemas without a corresponding migration script.

---

> [!IMPORTANT]
> **COMPLIANCE MANDATE**: Before ending any task, perform a full visual verification on BOTH the Domain and IP versions using the browser subagent. Any regression in the systems listed above is considered a FAILURE.

### Current Pillar Status

- [x] Identity Shield (V15 Fixed)
- [x] Deployment Sync (V15 Fixed)
- [x] Media Pulse (Monitoring)

---

Last Updated: 2026-03-25
