# Sovereign V15 Finance Debug Report & Test Log

Created: 2026-02-26 15:02:00

## 1. Test Scenario Overview

- **User ID:** SOV_TEST_777 (Test User)
- **Currency:** USD
- **Gateway:** Amarpay (Local)
- **Amount:** 10.00 USD
- **Target:** 01812345678 (bkash)
- **Expectation:** Deduct 10 USD + Tax, Convert to BDT for Batch, Send BDT to Gateway, Credit Referral on Success.

## 2. Execution Log (Step-by-Step)

| Step | Action | Status | Notes/Issues |
| :--- | :--- | :--- | :--- |
| 1 | Register/Login Test User | PENDING | Need to ensure unique meshID |
| 2 | Simulated Deposit (Credit) | PENDING | Must ensure signature integrity |
| 3 | Withdraw Request (Deduction) | PENDING | Check for correct ledger lock |
| 4 | Admin Approval Snapshot | PENDING | Verify bdt_rate storage in map |
| 5 | Batch Release (Conversion) | PENDING | Check USD -> BDT math precision |
| 6 | Gateway Response Simulation | PENDING | Test Success & Failure paths |
| 7 | MLM Commission Sync | PENDING | Confirm referrer gets 'fixed_commission' |

## 3. Potential Problem Notes (Watch-list)

- **[ ] Problem A:** Multi-currency mismatch during self-healing (Refund loop).
- **[ ] Problem B:** Double-taxation logic in `main.py` vs `Imperial Finance`.
- **[ ] Problem C:** WebSocket sync failure for Referrer's wallet update.

---
*This file will be updated live during the test execution.*
