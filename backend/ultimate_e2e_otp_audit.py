import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def ultimate_e2e_otp_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign OTP DNA ---")
    
    # Audit 1: Gateway Bridge (Nginx)
    print("\n--- AUDIT 1: GATEWAY BRIDGE ---")
    _, out1, _ = ssh.exec_command('docker logs --tail 20 sovereign_v15_gateway')
    print(out1.read().decode())
    
    # Audit 2: Backend Handling (FastAPI)
    print("\n--- AUDIT 2: BACKEND DNA ---")
    _, out2, _ = ssh.exec_command('docker logs --tail 50 sovereign_v15_backend')
    print(out2.read().decode())
    
    # Audit 3: SMTP Connection Proof
    print("\n--- AUDIT 3: SMTP HANDSHAKE TEST ---")
    # Testing if server can reach gmail smtp server
    _, out3, _ = ssh.exec_command('nc -zv smtp.gmail.com 587')
    _, err3, _ = ssh.exec_command('nc -zv smtp.gmail.com 587')
    print(f"SMTP Pulse: {out3.read().decode()} {err3.read().decode()}")
    
    # Audit 4: Credentials Check (Checking if gmail_engine.py is updated)
    print("\n--- AUDIT 4: GMAIL ENGINE DNA ---")
    _, out4, _ = ssh.exec_command('cat /root/sovereign/backend/gmail_engine.py')
    print(out4.read().decode())

    ssh.close()

if __name__ == "__main__":
    ultimate_e2e_otp_audit()

