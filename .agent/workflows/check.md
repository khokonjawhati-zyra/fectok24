---
description: Hair-splitting logic verification for FecTok V15
---

# Sovereign ULTRA-CHECK Protocol [V15]

This workflow performs a 100% hair-splitting logic verification for the requested feature.

## 1. IDENTITY & LOCALIZATION

- [ ] Use `grep_search` or `findstr` to locate the exact class and function definitions.
- [ ] Map the flow from frontend triggers (Flutter/Web) to backend endpoints (FastAPI/main.py).

## 2. FLOW ANALYSIS (The 100% Trace)

- [ ] **Input Audit**: Verify how data (payload) is received and sanitized.
- [ ] **Logic Audit**: Check the mathematical/logical operators (e.g. splits, multipliers, conditional guards).
- [ ] **Storage Audit**: Verify how data is written to the ledger (`users_manifest.json`, `config.json`, or sqlite).

## 3. SECURITY & INTEGRITY CHECK

- [ ] **Signature Logic**: Ensure `sign_balance` or similar HMAC guards are applied at the point of storage.
- [ ] **Rate Limiting**: Check if bot-guards, hardware-level limits, or cooldown periods exist.
- [ ] **Atomic Safety**: Verify if `atomic_save` or `ledger_lock` is used to prevent file corruption during concurrent writes.

## 4. PERSISTENCE VERIFICATION

- [ ] Confirm if the configuration survives server restarts by checking `_load` and `_save` logic.

## 5. FINAL 100% REPORT

- Generate a report following this format:
  - **Logic Status**: [OK / CRITICAL / FAIL]
  - **Security Status**: [MASTER-SECURE / VULNERABLE]
  - **Step-by-Step Breakdown**: (A precise trace with file names and line numbers)
  - **Conclusion**: 100% Certainty Verdict.
