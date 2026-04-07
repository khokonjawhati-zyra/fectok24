import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def fix_admin_auth_init_final():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. READ the entire main.py
    sftp = ssh.open_sftp()
    with sftp.open('/root/sovereign/backend/main.py', 'r') as f:
        content = f.read().decode('utf-8')
    sftp.close()
    
    # 2. Re-write admin_auth_init to be Bulletproof
    import re
    # Find the start of the function
    start_match = re.search(r'@app\.post\("/admin_auth_init"\)', content)
    if not start_match:
        print("ERROR: admin_auth_init not found.")
        ssh.close()
        return

    # Find the start of the next endpoint to get the boundary
    end_match = re.search(r'@app\.post\("/admin_auth_verify"\)', content)
    if not end_match:
        print("ERROR: admin_auth_verify not found.")
        ssh.close()
        return

    new_function = """@app.post("/admin_auth_init")
async def admin_auth_init(req: dict, request: Request):
    master = req.get("master_key")
    pin = req.get("pin")
    hwid = req.get("hwid")
    if not hwid: hwid = "LOCAL_DEV_NODE"
    client_ip = request.client.host if request.client else "unknown"

    # Sovereign V15: Localhost Admin Init Bypass [A_124]
    if client_ip in ["127.0.0.1", "localhost", "::1"]:
         otp = "000000"
         user_auth.admin_pulses[hwid] = {
             "otp": otp,
             "expiry": datetime.datetime.now() + datetime.timedelta(minutes=10),
             "attempts": 0
         }
         logger.info(f"ADMIN_PULSE: Localhost Bypass Init for Node {hwid}")
         return {"status": "SUCCESS"}

    # Neural Lockout Check
    lock_data = user_auth.admin_failed_nodes.get(hwid, {"count": 0, "lock": None})
    
    # Sovereign V15: High-Level Bypass Pulse
    master_clean = master.strip() if master else ""
    pin_clean = pin.strip() if pin else ""
    
    if master_clean == user_auth.ADMIN_MASTER_KEY and pin_clean == user_auth.ADMIN_PIN:
        logger.info(f"ADMIN_PULSE: Master override detected for node {hwid}. Flushing lockout.")
        user_auth.admin_failed_nodes[hwid] = {"count": 0, "lock": None}
    else:
        if lock_data["lock"] and lock_data["lock"] > datetime.datetime.now():
            retry_in = (lock_data["lock"] - datetime.datetime.now()).seconds
            return {"status": "REJECTED", "reason": f"TEMPORARY_BAN ({retry_in}s)"}

    # Advanced Validation Mesh (HWID RELAXED FOR V15.3)
    if master_clean == user_auth.ADMIN_MASTER_KEY and pin_clean == user_auth.ADMIN_PIN:
        otp = str(random.randint(100000, 999999))
        user_auth.admin_pulses[hwid] = {
            "otp": otp,
            "expiry": datetime.datetime.now() + datetime.timedelta(minutes=10),
            "attempts": 0
        }
        # Reset failures on successful handshake
        user_auth.admin_failed_nodes[hwid] = {"count": 0, "lock": None}
        
        logger.info(f"DEBUG: Triggering Admin OTP for {user_auth.ADMIN_TARGET_EMAIL} with code {otp}")
        import threading
        # Ensure targeted admin email
        threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp)).start()
        
        user_auth.log_admin_audit("AUTH_HANDSHAKE", f"Admin Node {hwid} ({client_ip}) initialized success pulse.")
        return {"status": "SUCCESS"}
    
    # Track Failure
    count = lock_data["count"] + 1
    lock_time = None
    if count >= 5:
        lock_time = datetime.datetime.now() + datetime.timedelta(minutes=30)
        user_auth.log_admin_audit("ADMIN_NODE_LOCKED", f"Failed Master Key for {hwid} from {client_ip}. Node Banned for 30m.")
    
    user_auth.admin_failed_nodes[hwid] = {"count": count, "lock": lock_time}
    logger.warning(f"ADMIN_SECURITY: Unauthorized Handshake Attempt [{count}/5] from {hwid}")
    return {"status": "REJECTED", "reason": "SEC_BREACH_DETECTED"}

"""
    
    new_content = content[:start_match.start()] + new_function + content[end_match.start():]
    
    # 3. WRITE it back
    sftp = ssh.open_sftp()
    with sftp.open('/root/sovereign/backend/main.py', 'w') as f:
        f.write(new_content)
    sftp.close()
    
    # 4. RESTART
    print("Restarting backend...")
    ssh.exec_command('docker restart sovereign_v15_backend')
    ssh.close()
    print("DONE.")

if __name__ == "__main__":
    fix_admin_auth_init_final()

