import logging
import json
import os
import hmac
import hashlib
import random
import datetime
import asyncio
from decimal import Decimal, ROUND_HALF_UP

# Sovereign V15: Imperial Finance Engine
# Objective: Secure, Admin-Controlled, Batch-Payout System (AmarPay Integration)
# Methodology: Sovereign Safe-Inject Protocol (Isolation & Integrity)

logger = logging.getLogger("uvicorn")

# Sovereign V15: Persistence Path Normalization
IS_DOCKER = os.path.exists('/.dockerenv')
AUTH_DATA_DIR = "/app/auth_data" if IS_DOCKER else "."

class ImperialFinance:
    def __init__(self):
        # Phase 6: Auth Path Normalization [Imperial Record Protection]
        self.ledger_file = os.path.join(AUTH_DATA_DIR, "payout_batch_ledger.json")
        self.audit_log = os.path.join(AUTH_DATA_DIR, "payout_audit.log")
        self.config_file = os.path.join(AUTH_DATA_DIR, "imperial_config.json")
        self.ledger_secret = os.getenv("IMPERIAL_SECRET", "SOVEREIGN_V15_IMPERIAL_FINANCE_SECRET")
        
        # Phase 1: Core Structures
        self.batch_queue = []
        self.admin_reserve = 0.0 # BDT
        self.usd_to_bdt_rate = 115.0
        self.kill_switch_engaged = False
        self.spread_guard_enabled = True # A_150
        
        self._load_ledger()
        self._load_config()

    def _load_ledger(self):
        if os.path.exists(self.ledger_file):
            try:
                with open(self.ledger_file, 'r') as f:
                    self.batch_queue = json.load(f)
                logger.info(f"Imperial Finance: Loaded {len(self.batch_queue)} pending batch items.")
            except Exception as e:
                logger.error(f"Imperial Finance Ledger Load Error: {e}")
                self.batch_queue = []

    def _save_ledger(self):
        try:
            # Sovereign V15: Atomic Write Protocol
            temp_path = f"{self.ledger_file}.tmp"
            with open(temp_path, 'w') as f:
                json.dump(self.batch_queue, f, indent=4)
            os.replace(temp_path, self.ledger_file)
        except Exception as e:
            logger.error(f"Imperial Finance Ledger Save Error: {e}")

    def _load_config(self):
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r') as f:
                    config = json.load(f)
                    self.admin_reserve = config.get("admin_reserve", 0.0)
                    self.usd_to_bdt_rate = config.get("usd_to_bdt_rate", 115.0)
                    self.kill_switch_engaged = config.get("kill_switch_engaged", False)
                    self.spread_guard_enabled = config.get("spread_guard_enabled", True)
            except Exception as e:
                logger.error(f"Imperial Finance Config Load Error: {e}")

    def send_admin_otp(self, user_auth_node):
        """
        Sovereign V15: A_143 2FA/OTP Protocol
        Hooks into the existing user_auth node to send email OTP.
        """
        # We simulate or call the existing send_admin_otp logic
        hwid = "ADMIN_NODE_ALPHA_V15"
        return user_auth_node.send_admin_otp(hwid)

    async def execute_amarpay_disbursement(self, entry: dict):
        """
        Sovereign V15: A_134 Unified Payout Dispatch [A_113 Convergence]
        Switches from local disbursement logic to the Master Payout Bridge.
        """
        from payout_bridge import governor
        
        logger.info(f"Imperial Finance: [A_113] Dispatching Batch Item {entry['batch_id']} to Bridge.")

        # The 'method' preserved in the entry (bkash/nagad) is used directly
        res = await governor.execute_payout(
            gateway=entry.get("gateway", "amarpay"),
            amount=entry["amount"],
            user_target=entry["account"],
            currency=entry["currency"],
            payout_id=entry["batch_id"]
        )

        if res.get("status") == "APPROVED":
            return {"status": "SUCCESS", "tx_ref": res.get("tx_ref")}
        else:
            return {"status": "FAILED", "reason": res.get("message", "Bridge Execution Rejected")}

    async def process_batch(self, admin_id: str, otp_verified: bool, ai_brain=None, ledger_secret=""):
        """
        Sovereign V15: A_135 Batch Processing Engine
        Updated with A_136 AI Guard and A_156 Kill-Switch
        """
        if self.kill_switch_engaged:
            logger.critical("Imperial Finance: EXECUTION BLOCKED. Kill-Switch is ACTIVE.")
            return {"status": "HALTED", "reason": "KILL_SWITCH_ACTIVE"}

        if not otp_verified:
            return {"status": "REJECTED", "reason": "MFA_REQUIRED"}

        logger.info(f"Imperial Finance: Starting Batch Execution for {len(self.batch_queue)} items.")
        
        results = []
        chunk_size = 50
        for i in range(0, len(self.batch_queue), chunk_size):
            chunk = self.batch_queue[i:i + chunk_size]
            
            for entry in chunk:
                if entry["status"] != "PENDING_AI_GUARD":
                    continue
                
                # Sovereign V15: Isolation for Direct Bank Transfer [Phase 1/4]
                if entry.get("gateway") == "bank" or entry.get("method") == "bank":
                    # Bank Payouts are handled via the manual 'Mark as Paid' Command Center
                    continue
                if ai_brain:
                    # 1. Integrity Check (A_137)
                    # Note: we'd need the actual user balance object here
                    
                    # 2. Fraud Filter (A_136) & A_154 Hardware Fingerprinting
                    is_safe = await ai_brain.v15_validate_financial_pulse(
                        entry["user_id"], 
                        entry["amount"], 
                        entry["currency"],
                        fingerprint=entry.get("hw_id", "UNKNOWN")
                    )
                    if not is_safe:
                        entry["status"] = "REJECTED_BY_AI"
                        entry["error"] = "AI_FRAUD_PROTOCOL_TRIGGERED"
                        self._save_ledger()
                        results.append(entry) # Ensure REJECTED items are reported for refund
                        continue

                    # 3. A_150 Currency Spread Guard [High Fidelity Protection]
                    if self.spread_guard_enabled:
                        snapshot_rate = entry.get("bdt_rate", self.usd_to_bdt_rate)
                        current_rate = self.usd_to_bdt_rate
                        diff_percent = abs(current_rate - snapshot_rate) / snapshot_rate
                        if diff_percent > 0.02: # 2% Threshold
                              entry["status"] = "REJECTED_BY_AI"
                              entry["error"] = "CURRENCY_VOLATILITY_GUARD_TRIGGERED"
                              self.log_audit("SPREAD_GUARD", entry["user_id"], 0, f"Rate shifted from {snapshot_rate} to {current_rate} (>2%)")
                              self._save_ledger()
                              results.append(entry) # Ensure REJECTED items are reported for refund
                              continue

                # Execute AmarPay Disbursement
                res = await self.execute_amarpay_disbursement(entry)
                
                if res.get("status") == "SUCCESS":
                    entry["status"] = "PAID"
                    entry["tx_ref"] = res.get("tx_ref")
                else:
                    entry["status"] = "FAILED"
                    entry["error"] = res.get("reason", "Unknown Gateway Error")
                
                results.append(entry)
                self._save_ledger()
                await asyncio.sleep(0.5)

        return {"status": "BATCH_COMPLETED", "details": results}

    def engage_kill_switch(self, reason: str):
        """Sovereign V15: A_156 Emergency Kill-Switch"""
        self.kill_switch_engaged = True
        self._save_config()
        self.log_audit("KILL_SWITCH", "SYSTEM", 0, f"REASON: {reason}")
        logger.critical(f"Imperial Finance: KILL-SWITCH ENGAGED! Reason: {reason}")

    def _get_amarpay_credentials(self):
        """Sovereign V15: Sync with Master Payout Bridge [A_113]"""
        from payout_bridge import governor
        config = governor.gateways.get("amarpay")
        if config and config.get("active"):
            return {
                "merchant_id": config.get("key"),
                "api_key": config.get("secret")
            }
        # Fallback to imperial local config if not found in governor
        if os.path.exists(self.config_file):
            with open(self.config_file, 'r') as f:
                c = json.load(f)
                return c.get("amarpay_gateway", {})
        return None

    def _save_config(self):
        try:
            temp_path = f"{self.config_file}.tmp"
            with open(temp_path, 'w') as f:
                json.dump({
                    "admin_reserve": self.admin_reserve,
                    "usd_to_bdt_rate": self.usd_to_bdt_rate,
                    "kill_switch_engaged": self.kill_switch_engaged,
                    "spread_guard_enabled": self.spread_guard_enabled
                }, f, indent=4)
            os.replace(temp_path, self.config_file)
        except Exception as e:
            logger.error(f"Imperial Finance Config Save Error: {e}")

    def log_audit(self, action: str, user_id: str, amount: float, details: str):
        """Sovereign V15: Immutable Audit Log (Append Only)"""
        ts = datetime.datetime.now().isoformat()
        entry = f"[{ts}] {action.upper()} | User: {user_id} | Amt: {amount} | Details: {details}\n"
        with open(self.audit_log, 'a', encoding='utf-8') as f:
            f.write(entry)

    def calculate_payout_fee(self, amount: float, gateway: str) -> float:
        """
        Sovereign V15: Dynamic Fee Engine
        AmarPay typically has transaction fees. This logic ensures the platform doesn't lose money.
        """
        # Default AmarPay Fee: 2% or flat rate (Adjustable by Admin)
        if gateway.lower() in ["bkash", "nagad"]:
            fee = round(amount * 0.02, 2) # 2% Fee
            return max(fee, 5.0) # Minimum 5 BDT fee
        return 0.0

    def sign_transaction(self, data: dict) -> str:
        """Sovereign V15: HMAC Quantum Hash Signature for Ledger Integrity"""
        msg = f"{data.get('user_id')}:{data.get('amount')}:{data.get('tax_rate', 0)}:{data.get('timestamp')}"
        return hmac.new(self.ledger_secret.encode(), msg.encode(), hashlib.sha256).hexdigest()

    def add_to_batch(self, user_id: str, amount: float, currency: str, gateway: str, account: str, hw_id: str = "UNKNOWN", tax_rate: float = 0.0, method: str = "bkash", original_currency: str = None, original_amount: float = None):
        """Sovereign V15: Queue a validated withdrawal for the monthly Pulse Window"""
        tax_amt = round(amount * (tax_rate / 100.0), 2)
        entry = {
            "batch_id": f"BCH_{int(datetime.datetime.now().timestamp())}_{random.randint(100, 999)}",
            "user_id": user_id,
            "amount": amount,
            "tax_rate": tax_rate,
            "tax_amount": tax_amt,
            "currency": currency,
            "original_currency": original_currency or currency, # V15 Tracker
            "original_amount": original_amount or amount, # V15 Tracker
            "original_tax_amount": round((original_amount or amount) * (tax_rate / 100.0), 2),
            "gateway": gateway,
            "method": method,
            "account": account,
            "hw_id": hw_id,
            "status": "PENDING_AI_GUARD",
            "timestamp": datetime.datetime.now().isoformat(),
        }
        entry["signature"] = self.sign_transaction(entry)
        
        self.batch_queue.append(entry)
        self._save_ledger()
        self.log_audit("QUEUE_BATCH", user_id, amount, f"Gateway: {gateway} | Tax: {tax_amt} ({tax_rate}%)")
        return entry["batch_id"]

    def update_admin_reserve(self, amount: float, action: str = "ADD"):
        """Sovereign V15: Manual Fund Injection Tracker (Admin Bank -> AmarPay Wallet)"""
        if action == "ADD":
            self.admin_reserve += amount
        else:
            self.admin_reserve -= amount
        self._save_config()
        self.log_audit("RESERVE_UPDATE", "ADMIN", amount, f"Action: {action} | New Reserve: {self.admin_reserve}")

    def reconcile_batch(self, batch_id: str, gateway_res: dict):
        """
        Sovereign V15: A_145 Reconciliation Engine
        Verifies batch execution results against the digital ledger.
        """
        success_count = 0
        terminal_status = gateway_res.get("status", "FAILED")
        
        for entry in self.batch_queue:
            if entry.get("batch_id") == batch_id or batch_id == "ALL_PENDING":
                entry["status"] = "PAID" if terminal_status == "SUCCESS" else "FAILED"
                entry["reconciled_at"] = datetime.datetime.now().isoformat()
                success_count += 1
        
        self._save_ledger()
        self.log_audit("RECONCILE", "SYSTEM", 0.0, f"Batch: {batch_id} | Status: {terminal_status} | Count: {success_count}")
        return success_count

    def mask_account(self, account: str) -> str:
        """Sovereign V15: A_157 PII Data Masking helper"""
        if not account or len(account) < 6: return "****"
        if "@" in account: # Email mask
            parts = account.split("@")
            return f"{parts[0][0]}***@{parts[1]}"
        # Phone mask
        return f"{account[:3]}****{account[-2:]}"

    def finalize_and_archive(self):
        """Sovereign V15: A_146 Archive PAID entries to clean the active ledger"""
        archive_file = "payout_archive_v15.json"
        # Archive anything that isn't PENDING
        processed_statuses = ["PAID", "FAILED", "REJECTED_BY_AI"]
        now_processed = [e for e in self.batch_queue if e.get("status") in processed_statuses]
        self.batch_queue = [e for e in self.batch_queue if e.get("status") not in processed_statuses]
        
        if now_processed:
            archive_data = []
            if os.path.exists(archive_file):
                try:
                    with open(archive_file, 'r') as f:
                        archive_data = json.load(f)
                except Exception: archive_data = []
            
            archive_data.extend(now_processed)
            
            with open(archive_file, 'w') as f:
                json.dump(archive_data, f, indent=4)
                
            self._save_ledger()
            self.log_audit("ARCHIVE_CLEANUP", "SYSTEM", 0.0, f"Archived {len(now_processed)} entries.")
            return len(now_processed)
        return 0

# Singleton Instance
imperial_finance = ImperialFinance()
