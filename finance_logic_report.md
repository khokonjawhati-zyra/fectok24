# Sovereign V15: Technical Financial Logic Report 📊

**Subject:** A_113 Quantum Wallet & Real-Money Transaction Orchestration
**Standard:** Sovereign Master V15 [Chain-Reaction]

## 1. The Multi-Layered Wallet Architecture

The system treats user balances not as a simple number, but as a sum of states:

- **Available Balance:** Real-time spendable fiat/coins.
- **Pending/Frozen Balance:** Funds locked during withdrawal or trade verification.
- **Admin Ledger:** The platform's ecosystem fuel (commissions collected).

## 2. Webhook Authentication Security (The Secret Hook)

To prevent "Fiscal Injection" (fake balance addition), the system utilizes:

- **Challenge-Response Handshake:** Every signal from Bkash/Nagad must contain a `Signature` header.
- **HMAC Check:** Our server re-calculates the signature using the `App_Secret`. If result A != result B, the transaction is logged as `FRAUD` and the IP is immediately banned (A_106).

## 3. Withdrawal Integrity Watchdog

Withdrawals are not just balance checks; they are performance audits:

- **Step 1:** Verify user `Total_Ad_Watch_Time` vs `Requested_Withdrawal`.
- **Step 2:** Admin Truth Verification (A_108). The admin panel provides the final "human" layer of approval.
- **Step 3:** Atomic Deduction. The wallet is updated *after* the Payout API returns `SUCCESS: DISBURSED`.

## 4. Double-Entry Asset Ledger [DEAL]

Every transaction generates two entries:

1. **Entry A (User):** Debit/Credit to `ledger.json`.
2. **Entry B (Platform):** Offset to `admin_revenue.json`.
This ensures that the total money in the system always equals (Total User Deposits - Total Platform Payouts).

## 5. Dynamic Revenue Split [A_105/A_111 Sync]

The logic retrieves its mathematical constants (Commission %, BDT Rate, Conversion Tax) from the Admin Panel in real-time. This allows the admin to adjust profit margins without restarting the backend.

## 6. The Sovereign Payout Bridge (C_113)

Implemented a non-destructive gateway router (`payout_bridge.py`):

- **Hook Mapping:** Seamlessly connects `A_113_TRANSACTION_DECISION` and `AD_API_UPDATE` to production gateway drivers.
- **Fail-Safe Mode:** If Admin Keys are absent, the system holds in 100% Simulation Mode.
- **Atomic Payout:** Production Payout API is triggered via asynchronus tasks to ensure Admin Panel responsiveness.

---
**Report Updated by Sovereign AI**
**Status:** Phase 1 (Bridge Injection) - COMPLETE
**Timestamp:** 2026-02-19T23:55:00
