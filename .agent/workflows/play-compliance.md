---
description: Sovereign V15 Play Store Compliance Roadmap [Decoupled Strategy]
---

# Sovereign V15: Google Play Compliance Protocol

This workflow outlines the final surgical steps to ensure 100% compliance with Google Play Store policies before submission. **CRITICAL: Apply these steps ONLY at the final deployment stage.**

## 1. UI Gating (Mobile vs. Web)

Use `kIsWeb` guards in `main.dart` to hide the following from Mobile builds:

- [ ] MLM Network [A_107]
- [ ] Quantum Wallet [A_113]
- [ ] Sponsored Templates [A_111]
- [ ] Deposit/Withdraw buttons

## 2. Payment Policy Shield

- [ ] Ensure NO direct payment gateways (bKash/Nagad/Cards) are visible in Android/iOS builds.
- [ ] Link to the official Web Portal for financial management.

## 3. Financial Terminology Scrub

- [ ] Replace financial terms (USD, BDT, Yield) with "Credits", "Points", or "Social Power" in Mobile-facing strings.

## 4. UGC Safety Verification

- [ ] Confirm Account Deletion button is active in Settings.
- [ ] Confirm Content/User Reporting system is functional.
- [ ] Verify Privacy Policy link is accessible and updated with support contact.

## 5. Review-Mode Switch

- [ ] Implement a server-side `review_mode` flag in `main.py` that, when active, forces all clients to hide advanced features during the app review period.

---
**[Sovereign Compliance: Mobile Privacy Enabled | Admin God-Mode Intact]**
