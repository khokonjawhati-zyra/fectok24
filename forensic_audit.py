import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def forensic_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 1. CONTAINER PULSE ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps --format '{{.Names}} - {{.Status}}'")
    print(stdout.read().decode())
    
    print("\n--- 2. BACKEND LOG AUDIT (LAST 50 LINES) ---")
    stdin, stdout, stderr = ssh.exec_command("docker logs --tail 50 sovereign_v15_backend")
    print(stdout.read().decode())
    print("ERRORS:")
    print(stderr.read().decode())
    
    print("\n--- 3. GATEWAY CONFIG INTEGRITY ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway nginx -t")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    forensic_audit()

