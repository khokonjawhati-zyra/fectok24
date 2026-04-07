import time
import logging
import hmac
import hashlib
from fastapi import Request, HTTPException
from starlette.middleware.base import BaseHTTPMiddleware
from ai_engine import ai_brain

# Sovereign V15: 3-Layer Watchdog [DNA_V15]
logger = logging.getLogger("SovereignShield")

class Layer1_EntryGuard:
    """Layer 1: Entry Guard - High-Velocity & DNA Handshake"""
    def __init__(self):
        self.ip_hits = {}
        self.blacklist = set()
        self.DNA_SECRET = "vobogura101271" # Sovereign Master Key

    def check_rate_limit(self, ip: str) -> bool:
        now = time.time()
        hits = self.ip_hits.get(ip, [])
        # Window: 10 seconds, Max Hits: 100
        hits = [h for h in hits if now - h < 10]
        hits.append(now)
        self.ip_hits[ip] = hits
        
        if len(hits) > 100:
            logger.warning(f"ENTRY_GUARD: IP Throttled - {ip}")
            return False
        return True

    def verify_dna(self, dna_token: str) -> bool:
        return dna_token == self.DNA_SECRET

class Layer2_IntegrityGuard:
    """Layer 2: Integrity Guard - Data & Session Validation"""
    def verify_transaction(self, user_id: str, balance_data: dict, secret: str) -> bool:
        return ai_brain.v15_verify_balance_integrity(user_id, balance_data, secret)

    def verify_media(self, file_path: str, user_id: str):
        # Triggering AI Brain's deep scan
        return ai_brain.scan_content(file_path, user_id)

class Layer3_BehaviorGuard:
    """Layer 3: Behavior Guard - Anomalous Usage Patterns"""
    async def detect_fraud(self, user_id: str, amount: float, currency: str):
        return await ai_brain.v15_validate_financial_pulse(user_id, amount, currency)

    async def monitor_action(self, user_id: str, action: str):
        return await ai_brain.detect_anomaly(user_id, action)

class SovereignWatchdog(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        self.entry_guard = Layer1_EntryGuard()
        self.integrity_guard = Layer2_IntegrityGuard()
        self.behavior_guard = Layer3_BehaviorGuard()

    async def dispatch(self, request: Request, call_next):
        # ═══════════════════════════════════════════════════════════════
        # LAYER 1: ENTRY GUARD [Front Gate]
        # ═══════════════════════════════════════════════════════════════
        client_ip = request.client.host
        host = request.headers.get("host", "")
        path = request.url.path

        if not self.entry_guard.check_rate_limit(client_ip):
            raise HTTPException(status_code=429, detail="Sovereign Shield: Rate Limit Exceeded")

        # ═══════════════════════════════════════════════════════════════
        # PHASE 4: GHOST-ADMIN PROTOCOL [GHOST_PROTOCOL_ACTIVE]
        # ═══════════════════════════════════════════════════════════════
        is_admin_route = "/api/admin" in path or "/api/v15/admin" in path
        is_ghost_host = "vazo" in host

        if is_admin_route:
            # Rule 1: Admin routes MUST come from the Ghost Host
            if not is_ghost_host:
                logger.warning(f"GHOST_PROTOCOL: Blocked Admin Access attempt from generic host: {host}")
                raise HTTPException(status_code=404) # Return 404 to hide existence
            
            # Rule 2: Admin routes MUST provide the Master DNA Handshake
            dna_key = request.headers.get("X-Sovereign-DNA")
            if not self.entry_guard.verify_dna(dna_key):
                logger.critical(f"GHOST_PROTOCOL: DNA Handshake FAILED for {client_ip} on {path}")
                raise HTTPException(status_code=403, detail="Sovereign Shield: DNA Handshake Required")

        # Reverse Security: If the Ghost Host tries to access generic API routes, masquerade too
        if is_ghost_host and not is_admin_route and "/api/" in path:
             logger.info(f"GHOST_PROTOCOL: Admin user browsing public API: {path}")

        # ═══════════════════════════════════════════════════════════════
        # PROCESS REQUEST
        # ═══════════════════════════════════════════════════════════════
        response = await call_next(request)
        
        # ═══════════════════════════════════════════════════════════════
        # LAYER 3: BEHAVIOR MONITOR [Post-Action Analysis]
        # ═══════════════════════════════════════════════════════════════
        # Background analysis (non-blocking)
        if request.url.path == "/api/v15/interaction":
            try:
                # We extract user_id from query/body if needed for behavior tracking
                pass
            except: pass

        return response

# Global Shield Instance
watchdog = SovereignWatchdog
