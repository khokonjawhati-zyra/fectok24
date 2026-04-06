import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def deep_e2e_engine_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Deep Engine Pulse ---")
    
    # Audit 1: Check actual routes in main.py
    print("\n--- AUDIT 1: ROUTE VERIFICATION ---")
    _, out1, _ = ssh.exec_command('grep -E "async def (forgot|recover|reset)" /root/sovereign/backend/main.py -A 10')
    print(out1.read().decode())
    
    # Audit 2: SMTP DNA Internal Status
    print("\n--- AUDIT 2: SMTP DNA STATUS ---")
    _, out2, _ = ssh.exec_command('docker logs --tail 100 sovereign_v15_backend | grep -iE "smtp|gmail|engine|email"')
    print(out2.read().decode())
    
    # Audit 3: Manual SMTP Handshake from Container
    print("\n--- AUDIT 3: MANUAL CONTAINER HANDSHAKE ---")
    # Using python directly in the container to test SMTP logic
    _, out3, _ = ssh.exec_command('docker exec sovereign_v15_backend python3 -c "import smtplib; s = smtplib.SMTP(\'smtp.gmail.com\', 587); s.starttls(); print(\'SMTP Handshake Success: \', s.ehlo()[0])"')
    print(out3.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    deep_e2e_engine_audit()

