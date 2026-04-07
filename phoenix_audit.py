import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def phoenix_recovery_audit():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 2. HOST LISTENING PORTS (Check if 80/5000 are alive) ---")
    stdin, stdout, stderr = ssh.exec_command("netstat -tulpn | grep -E '80|443|5000|8080' || echo 'No ports listening'")
    print(stdout.read().decode())
    
    print("--- 3. DETAILED CONTAINER LOGS ---")
    for s in ["sovereign_v15_gateway", "sovereign_v15_backend"]:
        print(f"\n>>> LOGS FOR {s}:")
        stdin, stdout, stderr = ssh.exec_command(f"docker logs --tail 30 {s}")
        print("STDOUT:", stdout.read().decode())
        print("STDERR:", stderr.read().decode())
        
    print("--- 4. NGINX SYNTAX VALIDATION ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway nginx -t")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    phoenix_recovery_audit()

