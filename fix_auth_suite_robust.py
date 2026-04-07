import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def inject_hyperv15_auth_robust():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Read the whole file
    sftp = ssh.open_sftp()
    with sftp.open('/root/sovereign/backend/main.py', 'r') as f:
        content = f.read().decode('utf-8')
    sftp.close()
    
    import re
    # Match the whole block between the decorators
    start_match = re.search(r'@app\.post\("/admin_auth_init"\)', content)
    end_match = re.search(r'@app\.post\("/admin_auth_verify"\)', content)
    next_match = re.search(r'@app\.post\("/check_referral"\)', content)

    if not start_match or not end_match or not next_match:
        print("ERROR: Endpoints not found.")
        ssh.close()
        return

    admin_auth_init_new = """@app.post("/admin_auth_init")
async def admin_auth_init(req: dict, request: Request):
    master = req.get("master_key", "").strip()
    pin = req.get("pin", "").strip()
    hwid = req.get("hwid", "ADMIN_NODE_ALPHA_V15").strip()
    client_ip = request.client.host if request.client else "unknown"

    logger.info(f"ADMIN_INIT_PULSE: Node={hwid}, IP={client_ip}")

    # 1. Master Check
    if master == user_auth.ADMIN_MASTER_KEY and pin == user_auth.ADMIN_PIN:
        # Success logic - Bulletproof return
        otp = str(random.randint(100000, 999999))
        user_auth.admin_pulses[hwid] = {
            "otp": otp,
            "expiry": datetime.datetime.now() + datetime.timedelta(minutes=10),
            "attempts": 0
        }
        # Reset any bans
        user_auth.admin_failed_nodes[hwid] = {"count": 0, "lock": None}
        
        logger.info(f"PULSE_AUTHORISED: Level 1 Handshake OK for {hwid}. Dispatching OTP.")
        
        import threading
        threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp)).start()
        
        return {"status": "SUCCESS"}
    
    # 2. Failure Path
    logger.warning(f"PULSE_REJECTED: Unauthorized credentials for node {hwid}")
    return {"status": "REJECTED", "reason": "SEC_BREACH_DETECTED"}
"""

    admin_auth_verify_new = """@app.post("/admin_auth_verify")
async def admin_auth_verify(req: dict, request: Request):
    otp = req.get("otp", "").strip()
    hwid = req.get("hwid", "ADMIN_NODE_ALPHA_V15").strip()
    client_ip = request.client.host if request.client else "unknown"

    logger.info(f"ADMIN_VERIFY_PULSE: Node={hwid}, OTP={otp}")

    # Localhost / Dev Node Bypass
    if (client_ip in ["127.0.0.1", "localhost", "::1"]) and otp == "000000":
         token = user_auth.generate_token("MASTER_ADMIN")
         return {"status": "SUCCESS", "token": token}

    pulse = user_auth.admin_pulses.get(hwid)
    if pulse:
        if pulse["otp"] == otp:
            if pulse["expiry"] > datetime.datetime.now():
                token = user_auth.generate_token("MASTER_ADMIN")
                del user_auth.admin_pulses[hwid]
                logger.info(f"ADMIN_PULSE_AUTHORISED: Access Granted to {hwid}")
                return {"status": "SUCCESS", "token": token}
            else:
                return {"status": "REJECTED", "reason": "OTP_EXPIRED"}
        else:
            pulse["attempts"] = pulse.get("attempts", 0) + 1
            if pulse["attempts"] >= 3:
                del user_auth.admin_pulses[hwid]
                return {"status": "REJECTED", "reason": "PULSE_BURNED"}
            return {"status": "REJECTED", "reason": "INVALID_OTP"}
    
    return {"status": "REJECTED", "reason": "INVALID_PULSE"}
"""

    # Assemble new content
    pre = content[:start_match.start()]
    post = content[next_match.start():]
    new_content = pre + admin_auth_init_new + "\n" + admin_auth_verify_new + "\n" + post
    
    # WRITE
    sftp = ssh.open_sftp()
    with sftp.open('/root/sovereign/backend/main.py', 'w') as f:
        f.write(new_content)
    sftp.close()
    
    print("Surgical auth rewrite complete. Restarting...")
    ssh.exec_command('docker restart sovereign_v15_backend')
    ssh.close()

if __name__ == "__main__":
    inject_hyperv15_auth_robust()

