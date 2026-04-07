import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def diagnose_v15():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 1. DIRECTORY AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command(f"ls -la {DEST_DIR}")
    print(stdout.read().decode())
    
    print("--- 2. DOCKER COMPOSE PS ---")
    stdin, stdout, stderr = ssh.exec_command(f"cd {DEST_DIR} && docker-compose ps")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    print("--- 3. DOCKER COMPOSE LOGS (ERROR SCAN) ---")
    stdin, stdout, stderr = ssh.exec_command(f"cd {DEST_DIR} && docker-compose logs --tail 50")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    print("--- 4. SYSTEM RESOURCE CHECK ---")
    stdin, stdout, stderr = ssh.exec_command("free -m && df -h")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    diagnose_v15()

