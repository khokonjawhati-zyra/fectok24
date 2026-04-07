import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_backend_dependencies():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Check backend logs for Redis/Mirror Sync connection issues
    print("--- Searching backend logs for Redis/Pulse errors ---")
    stdin, stdout, stderr = ssh.exec_command('docker logs sovereign_v15_backend 2>&1 | grep -iE "redis|pulse|refused|error"')
    print(stdout.read().decode())
    
    # 2. Check if redis container is actually listening internally
    print("--- Checking redis container (sovereign_v15_pulse) logs ---")
    stdin, stdout, stderr = ssh.exec_command('docker logs sovereign_v15_pulse --tail 10')
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_backend_dependencies()

