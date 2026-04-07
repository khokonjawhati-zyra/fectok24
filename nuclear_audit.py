import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def nuclear_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 1. ALL CONTAINERS ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps -a --format 'table {{.Names}}\t{{.Status}}'")
    print(stdout.read().decode())
    
    print("\n--- 2. BACKEND CRASH LOGS ---")
    stdin, stdout, stderr = ssh.exec_command("docker logs sovereign_v15_backend")
    # Starlette often prints error to stderr
    print(stderr.read().decode())
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    nuclear_audit()

