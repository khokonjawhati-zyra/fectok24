# 🗺️ Sovereign V15 'Dual-Pulse' Financial Roadmap

## Protocol: Gateway Transition & Graph Alignment (A_113)

**IMPORTANT:** This roadmap is designed with a "Non-Destructive Logic Guard". The core financial calculations, ledger integrity, tax rates, and BDT conversion logic currently in the system will remain **100% untouched**. We are only changing the **Payment Gateway Layer (Amarpay)** and aligning the data flow with the Sovereign V15 Visual Graph.

---

### Phase 1: Gateway DNA Alignment (The Amarpay Junction)

*Objective: Replace/Inject Amarpay credentials into the existing bridge without breaking the ledger.*

- **Step 1.1:** Map existing `governor.gateways` to Amarpay's structure (`merchant_id`, `signature_key`).
- **Step 1.2:** Ensure Admin Panel configuration pulses update the `sovereign_vault_v15.json` with Amarpay credentials.
- **Logic:** We use the existing "Armed/Inactive" switch to toggle Amarpay without changing how balances are stored.

### Phase 2: The Red Pulse (Automatic Deposit Logic) - [Graph Verified]

*Objective: Implement the direct flow from Gateway to User Balance.*

- **Step 2.1:** Update `payout_bridge.initiate_deposit` to support Amarpay’s `/jsonpost.php` session creation.
- **Step 2.2:** Create the `api/v15/finance/webhook/amarpay` endpoint in `main.py`.
- **Step 2.3:** Implement **Verification Pulse:** Before crediting any balance, the backend will call Amarpay's Verification API to confirm 100% success.
- **Pulse:** Once verified, trigger the existing `A_113_WALLET_SYNC` pulse to update the user's BDT Asset box immediately.

### Phase 3: The Green Pulse (Batch-Driven Withdraw) - [Graph Verified]

*Objective: Align withdrawal requests with the Batch Release Protocol.*

- **Step 3.1:** Maintain the current `A_113_TRANSACTION_SUBMIT` flow but mark Amarpay as the primary Payout Rail.
- **Step 3.2:** Ensure requests stay in the "Pending Table" and do NOT deduct balance until the Batch Authority is triggered.
- **Logic:** This preserves the "Hold" logic shown in the green arrows of the graph.

### Phase 4: Master Authority (The Pink Bar - A_136)

*Objective: Connect the Batch Release button to the payout execution.*

- **Step 4.1:** Link the "RELEASE SOVEREIGN FUNDS BATCH" button to a new backend handler.
- **Step 4.2:** This handler will iterate through the "Pending Withdraws" and execute the final balance deduction logic that is already present in the system.
- **Logic:** No change to math; only the *timing* of the execution is moved to the Batch Release event.

### Phase 5: Omni-Sync & UI Fidelity

*Objective: Ensure real-time updates across the mesh.*

- **Step 5.1:** Apply the "State-Pressure Patch" to both Deposit/Withdraw tables so they update in real-time when a Status Changes.
- **Step 5.2:** Final audit to ensure the transition from the old gateway to Amarpay hasn't shifted any precision scores.

---
**[Sovereign V15: Dual-Pulse Roadmap LOCKED | Core Logic Preserved]**
