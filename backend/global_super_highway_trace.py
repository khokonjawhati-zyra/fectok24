import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def global_super_highway_trace():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Super-Highway Pulse ---")
    
    # Audit 1: Check if Gateway is successfully handing over to Backend
    print("\n--- STEP 1: GATEWAY TO BACKEND HANDSHAKE ---")
    _, out1, _ = ssh.exec_command('docker logs --tail 20 sovereign_v15_gateway')
    logs_gw = out1.read().decode()
    print(logs_gw)
    
    # Audit 2: Check Backend Error DNA (Specific to Email)
    print("\n--- STEP 2: BACKEND EMAIL LOGS ---")
    _, out2, _ = ssh.exec_command('docker logs --tail 20 sovereign_v15_backend')
    logs_be = out2.read().decode()
    print(logs_be)
    
    # Audit 3: Raw SMTP Outbound Check from Host
    print("\n--- STEP 3: HOST OUTBOUND SMTP CHECK ---")
    _, out3, _ = ssh.exec_command('nc -zv smtp.gmail.com 587')
    _, err3, _ = ssh.exec_command('nc -zv smtp.gmail.com 587')
    print(f"Host SMTP Status: {out3.read().decode()} {err3.read().decode()}")

    # Audit 4: Manual Test Email Dispatch from Backend Shell
    print("\n--- STEP 4: MANUAL ENGINE DISPATCH ATTEMPT ---")
    test_cmd = "docker exec sovereign_v15_backend python3 -c \"import smtplib; s = smtplib.SMTP('smtp.gmail.com', 587, timeout=10); s.starttls(); print('Ready to send:', s.ehlo()[0])\""
    _, out4, _ = ssh.exec_command(test_cmd)
    _, err4, _ = ssh.exec_command(test_cmd)
    print(f"Engine Dispatch Status: {out4.read().decode()} {err4.read().decode()}")

    ssh.close()

if __name__ == "__main__":
    global_super_highway_trace()

