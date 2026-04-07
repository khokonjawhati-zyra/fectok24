import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def a_to_z_forensic_audit():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. HOST NETWORKING AUDIT (Are ports 80/5000 bound?) ---")
    stdin, stdout, stderr = ssh.exec_command("netstat -tulpn | grep -E '80|5000'")
    print(stdout.read().decode())
    
    print("\n--- 3. DOCKER PORT MAPPING AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps --format '{{.Names}}: {{.Ports}}' | grep sovereign_v15")
    print(stdout.read().decode())
    
    print("\n--- 4. NGINX INTERNAL FILE AUDIT (The real static path) ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/admin/index.html")
    print("Admin Index Check:", stdout.read().decode() or "MISSING!")
    
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/user/index.html")
    print("User Index Check:", stdout.read().decode() or "MISSING!")
    
    print("\n--- 5. NGINX ACTIVE CONFIG DUMP (No more guessing) ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway nginx -T")
    print(stdout.read().decode())
    
    print("\n--- 6. GATEWAY ERROR LOGS (Live pulse) ---")
    stdin, stdout, stderr = ssh.exec_command("docker logs --tail 20 sovereign_v15_gateway")
    print(stderr.read().decode())
    
    ssh.close()
    print("\n--- AUDIT COMPLETE: GAP IDENTIFIED ---")

if __name__ == "__main__":
    a_to_z_forensic_audit()

