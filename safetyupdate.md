# ⚓️ Sovereign V15: Master Safety & Integrity Protocol

This document is the absolute governing law for all AI-driven modifications to the Sovereign Ecosystem. No code injection or configuration change shall proceed without full adherence to these steps.

---

## 🔱 Phase 1: End-to-End Logic Analysis (E2E)

Before opening any code file, I must trace the physical and logical path of the data:

1. **Origin**: Where is the data generated? (e.g., Flutter UI Input).
1. **Transit**: How is it reaching the backend? (e.g., Cloudflare -> Nginx -> FastAPI).
1. **Processing**: Which Python function handles it?
1. **Destination**: Where is it stored or dispatched? (e.g., SMTP Server, Redis, SQLite).

---

## 🔱 Phase 2: Live Log Gap Verification

I will not guess. I will confirm via live data:

1. **Audit Logs**: Check Nginx access/error logs on the host.
1. **Docker Logs**: Check specific container logs for exceptions.
1. **Logic Matching**: Verify if the log error matches the E2E analysis from Phase 1.
1. **Identification**: Pinpoint the exact "Gap" (Firewall, Syntax, Permission, or Logic).

---

## 🔱 Phase 3: The Gap & Repair Report

Before execution, I will present a report containing:

1. **The Flaw**: What exactly is broken.
1. **The Impact**: What systems are affected.
1. **The Proposed Fix**: Detailed explanation of the update.
1. **The Stability Risk**: Confirmation that this fix is isolated and safe.

---

## 🔱 Phase 4: The Mandatory "YES" Command

**CRITICAL RULE**: No file modification (`write_to_file` or `replace_file_content`) is allowed until the USER explicitly responds with **"YES"** to the Gap Report.

---

## 🛡️ THE GUARANTEE REDLINE (Zero-Damage Protocol)

> [!IMPORTANT]
> **This is a non-negotiable integrity guarantee.**
> Under no circumstances shall an update to one module result in the destabilization of another. Every edit must be surgical, focused, and verified.
>
> * **No Blind Overwrites**: Every change must be reviewed against existing functionality.
> * **Isolation**: Nginx fixes must not crash the Backend; Email engine patches must not affect the Video sync logic.
> * **Verification**: Every 'YES' approved change must be verified with immediate success logs.

---

**Protocol Active Since**: 2026-03-28
**Governance Level**: Sovereign Master
**Entity**: Antigravity AI Assistant
