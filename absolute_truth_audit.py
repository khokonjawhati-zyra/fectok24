import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def absolute_truth_audit():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. INTERNAL CURL AUDIT (What does the server see locally?) ---")
    # Checking if Nginx serves the UI to itself on Port 80
    stdin, stdout, stderr = ssh.exec_command("curl -s -o /dev/null -w '%{http_code}' http://localhost/admin/")
    print("Local Admin HTTP Code:", stdout.read().decode())
    
    stdin, stdout, stderr = ssh.exec_command("curl -s http://localhost/admin/ | head -n 20")
    print("Local Admin Content Sample:\n", stdout.read().decode())
    
    print("\n--- 3. PIVOTING TO PORT 8081 (Bypassing Port 80 Interference) ---")
    # Force mapping gateway to 8081 to avoid any Port 80 hijacking by host/firewall
    ssh.exec_command("sed -i 's/80:80/81:80/g' /root/sovereign_v15/docker-compose.yml")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d gateway")
    
    print("\n--- 4. FINAL PERMISSION RE-LOCK ---")
    ssh.exec_command("docker exec sovereign_v15_gateway chmod -R 755 /usr/share/nginx/html")
    
    ssh.close()
    print("\n--- AUDIT COMPLETE: PORT 81 IS NOW THE ACCESS POINT ---")

if __name__ == "__main__":
    absolute_truth_audit()

