import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_mismatch_logs():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Look for ADMIN_MISMATCH in logs
    stdin, stdout, stderr = ssh.exec_command('docker logs sovereign_v15_backend 2>&1 | grep -i "ADMIN" | tail -n 20')
    print("--- ADMIN LOGS ---")
    print(stdout.read().decode())
    
    # 2. Check main.py content and print it (Lines 5130-5190)
    print("\n--- CODE CHECK (Lines 5130-5190) ---")
    stdin, stdout, stderr = ssh.exec_command('sed -n "5130,5195p" /root/sovereign/backend/main.py')
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_mismatch_logs()

