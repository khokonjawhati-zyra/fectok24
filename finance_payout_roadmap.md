# Sovereign V15: Imperial Finance Payout Roadmap

**Status:** Planning & Concept Phase (MILITARY-GRADE ARMORED)
**Standard:** Sovereign V15 Chain-Reaction
**Methodology:** Sovereign Safe-Inject Protocol (Zero-Risk Guard)
**Objective:** Bulletproof, Admin-Controlled, Batch-Payout System (Ad Network Income -> User Revenue)

---

## 🛡️ Implementation Strategy: Sovereign Safe-Inject

1. **Isolation First:** Use `imperial_finance.py` as a standalone engine. No mixing with legacy MLM/Ad-View code.
2. **System Preservation:** Current **Revenue sharing**, **MLM logic**, and **Sponsor protocols** are designated as "Protected Assets". The new engine will only READ from these systems, never modify their core logic.
3. **MLM Snapshot Integrity:** The existing `process_withdrawal_commission` logic is a primary dependency. The new engine will use a **Fiscal Snapshot Protocol** to capture referrers and commission values at the moment of request, ensuring that your dynamic MLM commission system (Referrer auto-earnings) is triggered correctly during the batch execution phase.
4. **Non-Destructive Injection:** Existing `main.py` functions preserved. New features added via independent API nodes using the `v15_imperial_` naming convention to avoid variable collisions.
5. **Atomic State Guard:** Database writes to `ledger.json` use atomic locking to prevent race conditions between MLM earnings and Payout deductions.
6. **Zero-Break Rollback:** Every modification is designed to be instantly reversible. If the Revenue or MLM balance fluctuates unexpectedly, the system triggers a "Hard Stop".

---

## Phase 1: Core Financial Infrastructure [New Backend Structure]

- [ ] **A_130: Imperial Finance Engine (`imperial_finance.py`)**  
  - Dedicated module for AmarPay API handlers, fee calculations, and currency spread logic.
- [ ] **A_131: Quantum Ledger (`payout_batch_ledger.json`)**  
  - Secure vault for monthly pending requests with **HMAC Quantum Hash Signatures**.
- [ ] **A_132: Immutable Audit Log (`payout_audit.log`)**  
  - Encrypted, append-only logs for every financial event.
- [ ] **A_133: Admin Reserve Tracker**  
  - Manual "Fund Injection" logger to decouple Ad-Network income (Bank) from App Operations.

## Phase 2: AmarPay Disbursement API Integration [The Bridge]

- [ ] **A_134: API Handshake Protocol**  
  - Implement AmarPay Payout API with **A_142 Patch (IP Whitelisting)**.
- [ ] **A_135: Batch Processing Engine**  
  - **A_151 Patch:** Intelligent Rate Limiter (Chunking in groups of 50).
  - **A_144/A_155 Patch:** Idempotency & Global Mutex Locks (No duplicate payouts).
  - **A_148 Patch:** Async Status Query handling for gateway timeouts.
  - **A_158 Patch (MLM Bridge):** Hook for `process_withdrawal_commission` to ensure referrers are credited during batch execution.

## Phase 3: High-Security AI Guard [The Sifter]

- [ ] **A_136: Fraud Filter (AIEngine Sync)**  
  - **A_154 Patch:** Device/Hardware Fingerprinting to block Sybil/Multiple account attacks.
- [ ] **A_137: Financial Integrity Check**  
  - **A_141 Patch:** Signature verification to detect manual database tampering.
  - **A_150 Patch:** Currency Spread Guard (Live exchange rate protection).

## Phase 4: Admin Command Center [UI Updates]

- [ ] **A_138: Finance Command Console**  
  - Dashboard showing total monthly liabilities vs Gateway Merchant Balance.
  - **A_157 Patch:** PII Data Masking (Masked numbers in UI/Logs).
- [ ] **A_139: Risk & AI Analysis Panel**  
  - UI for reviewing flagged users and approving/rejecting accounts based on AI scores.
- [ ] **A_140: Master Execution (MFA)**  
  - **A_143 Patch:** 2FA/OTP mandatory requirement for batch execution.
  - **A_153/A_156 Patch:** Atomic State Machine & Emergency Kill-Switch.
- [ ] **REMOVAL:** Delete legacy manual number editing buttons from Admin UI.

## Phase 5: User Experience & Self-Service [UI Updates]

- [ ] **A_141: Wallet Alpha Upgrade**  
  - Multi-State visibility: `Reviewing (AI)` -> `Processing (Batch)` -> `Paid`.
- [ ] **A_142: Secure Binding Logic**  
  - **A_152 Patch:** Two-Step Account Binding (Double-entry + OTP for bKash/Nagad).
- [ ] **A_143: Pulse Window Notifications**  
  - Global countdown timer showing payment processing dates.
- [ ] **REMOVAL:** Disable profile/number editing 72h before the Pulse Window.

## Phase 6: Decommissioning & Audit [Cleanup]

- [ ] **A_144: Legacy Payout Purge**  
  - Disable all insecure/instant payout endpoints in `main.py`.
- [ ] **A_145: Reconciliation Engine**  
  - Final check: AmarPay Balance vs App Ledger vs Bank Statement.
- [ ] **A_146: Checkpointing Finalization**  
  - Resume partial batch failures logic active.

---

### Security Protocol (The Hard Rules)

1. **Manual Refill Only:** The system CANNOT touch the Admin's bank account directly.
2. **Fixed Window Payouts:** No disbursement allowed outside the monthly "Pulse Window".
3. **Idempotency Fingerprint:** No payment processed without a unique Transaction Hash.
4. **MFA Enforcement:** Mandatory Mobile OTP for triggering any Batch Payout.
5. **PII Masking:** 0.0% raw bKash/Nagad numbers displayed to support staff.
6. **Isolated Storage:** Financial ledgers stored separately from general user data.
7. **Legacy Protection:** MLM and Revenue earning logic must remain 100% untouched.

**[Imperial Finance: V15 SECURE DISBURSEMENT GOVERNANCE - ULTIMATE ARMORED]**
