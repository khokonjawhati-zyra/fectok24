import os
import json
import logging
import urllib.request
import urllib.error

logger = logging.getLogger("QuantumSync")

# ═══════════════════════════════════════════════════════════════
# Sovereign V15: Brevo HTTP Email Engine [SMTP-Free Protocol]
# PORT 443 HTTPS — Works on all VPS (No SMTP block issues)
# ═══════════════════════════════════════════════════════════════

BREVO_API_KEY = os.getenv("BREVO_API_KEY")
BREVO_API_URL = "https://api.brevo.com/v3/smtp/email"
SENDER_EMAIL = os.getenv("SENDER_EMAIL", "noreply@fectok.com")  # Verified Domain Sender [DKIM+DMARC]
SENDER_NAME = "FecTok"

class RobustSMTPBridge:
    """
    Sovereign V15: Brevo HTTP API Engine
    Replaces SMTP with HTTPS-based delivery.
    Works even when VPS providers block port 587/465.
    """
    
    def __init__(self):
        self.api_key = BREVO_API_KEY
        self.api_url = BREVO_API_URL
        self.retry_limit = 3
        logger.info("RobustSMTPBridge: Brevo HTTP Engine Engaged [SMTP-Free Mode]")

    def send_email(self, sender_email: str, to_email: str, subject: str, body_html: str) -> bool:
        """
        Send email via Brevo HTTP API (port 443 — always open).
        Returns True on success, False on failure.
        """
        to_email = to_email.replace("\n", "").replace("\r", "").strip()
        
        payload = {
            "sender": {
                "name": SENDER_NAME,
                "email": SENDER_EMAIL
            },
            "to": [
                {"email": to_email}
            ],
            "subject": subject,
            "htmlContent": body_html
        }
        
        payload_bytes = json.dumps(payload).encode("utf-8")
        
        headers = {
            "accept": "application/json",
            "content-type": "application/json",
            "api-key": self.api_key
        }
        
        for attempt in range(self.retry_limit):
            try:
                req = urllib.request.Request(
                    self.api_url,
                    data=payload_bytes,
                    headers=headers,
                    method="POST"
                )
                with urllib.request.urlopen(req, timeout=15) as response:
                    resp_body = response.read().decode("utf-8")
                    logger.info(f"BREVO_PULSE_SUCCESS: Email delivered to {to_email} [Attempt {attempt + 1}] | Response: {resp_body[:100]}")
                    return True
                    
            except urllib.error.HTTPError as e:
                err_body = e.read().decode("utf-8") if e.fp else "No body"
                logger.error(f"BREVO_HTTP_ERROR [{attempt + 1}/{self.retry_limit}]: {e.code} {e.reason} | {err_body}")
            except urllib.error.URLError as e:
                logger.error(f"BREVO_URL_ERROR [{attempt + 1}/{self.retry_limit}]: {e.reason}")
            except Exception as e:
                logger.error(f"BREVO_PULSE_RETRY [{attempt + 1}/{self.retry_limit}]: {e}")
        
        logger.error(f"BREVO_ENGINE: FAILED to deliver pulse to {to_email} after {self.retry_limit} attempts.")
        return False


# Global Engine Instance
gmail_engine = RobustSMTPBridge()
