# SOVEREIGN MLM V15 CONSTITUTION: THE CHAIN-REACTION STANDARD

## 💎 CORE OBJECTIVE

To maintain a permanent, immutable, and real-time MLM commission ecosystem where referrers are credited instantly upon admin-approved withdrawals.

## 🧠 RECOGNIZED LOGIC (SYSTEM MEMORY)

### Layer 1: Persistent Infrastructure

- **Config Storage**: All fiscal rates (Yield %, Activation Fee, BDT Rate) MUST be persisted in `config.json`.
- **Referral Registry**: User-to-Referrer relationships MUST be stored in `referral_map.json`.
- **Referrer Auto-Enrollment**: If the system detects a referrer ID that doesn't exist in the ledger yet, it MUST automatically initialize that node to prevent "missing parent" errors.

### Layer 2: The Fiscal Chain-Reaction

1. **Trigger**: Every `A_113_TRANSACTION_DECISION` (Withdrawal Approval) MUST trigger the commission engine.
2. **Audit**: The system looks up the withdrawing User in the `referral_map.json`.
3. **Calculation**: `Commission = Approved_Amount * (Yield_Percentage / 100)`.
4. **Instant Credit**: The calculated amount is added to the Referrer's balance in `ledger.json` **before** the transaction is finalized.

### Layer 3: Visual & Real-Time Synchronization

- **Wallet Sync**: The Referrer MUST receive an immediate `A_113_WALLET_SYNC` signal to update their UI balance.
- **Admin Badge**: The Admin Panel MUST receive the `A_107_MLM_YIELD` broadcast to display the neon **"MLM REWARD SYNCED"** badge in the Withdrawal Archive.
- **Audit Logging**: Every commission event MUST be logged with the prefix `MLM:`.

## ⛔ GUARDIAN RULES

1. **NEVER** delete the `referral_map.json` lookup during backend updates.
2. **NEVER** finalize a withdrawal approval without checking for a potential commission parent.
3. **NEVER** hardcode rates that are meant to be dynamic via the Admin Panel.

### STATUS: LOCKED | VERSION: 15.0 (CHAIN-REACTION)
