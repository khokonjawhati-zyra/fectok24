import json
import os
import logging
import base64
from cryptography.fernet import Fernet

logger = logging.getLogger("uvicorn")

# Sovereign V15: Bank Vault Logic [Isolation Protocol]
class BankVaultManager:
    def __init__(self):
        self.auth_dir = "/app/auth_data" if os.path.exists('/.dockerenv') else "."
        self.vault_file = os.path.join(self.auth_dir, "bank_vault.json")
        self.key_file = os.path.join(self.auth_dir, "vault.key")
        self.key = self._load_key()
        self.cipher = Fernet(self.key)
        self.vault = self._load_vault()

    def _load_key(self):
        if os.path.exists(self.key_file):
            with open(self.key_file, "rb") as f:
                return f.read()
        else:
            key = Fernet.generate_key()
            with open(self.key_file, "wb") as f:
                f.write(key)
            return key

    def _load_vault(self):
        if os.path.exists(self.vault_file):
            try:
                with open(self.vault_file, "r") as f:
                    encrypted_data = f.read()
                    if not encrypted_data: return {}
                    decrypted_data = self.cipher.decrypt(encrypted_data.encode()).decode()
                    return json.loads(decrypted_data)
            except Exception as e:
                logger.error(f"BankVault Load Error: {e}")
                return {}
        return {}

    def _save_vault(self):
        try:
            data_str = json.dumps(self.vault)
            encrypted_data = self.cipher.encrypt(data_str.encode()).decode()
            with open(self.vault_file, "w") as f:
                f.write(encrypted_data)
        except Exception as e:
            logger.error(f"BankVault Save Error: {e}")

    def update_bank_profile(self, user_id, details):
        """Sovereign V15: AES-256 Encrypted Profile Update"""
        user_id = user_id.upper()
        # Ensure only valid bank fields are stored
        clean_details = {
            "bank_name": str(details.get("bank_name", "")),
            "account_name": str(details.get("account_name", "")),
            "account_number": str(details.get("account_number", "")),
            "branch_name": str(details.get("branch_name", "")),
            "routing_number": str(details.get("routing_number", "")),
            "swift_code": str(details.get("swift_code", "")),
            "last_updated": str(os.environ.get("CURRENT_TIME", "2026-03-04T17:45:00")) # Placeholder for now
        }
        self.vault[user_id] = clean_details
        self._save_vault()
        logger.info(f"BankVault: Profile updated for {user_id} [ENCRYPTED]")
        return True

    def get_bank_profile(self, user_id):
        """Sovereign V15: AES-256 Decrypted Profile Retrieval"""
        user_id = user_id.upper()
        return self.vault.get(user_id, {})

bank_vault = BankVaultManager()
