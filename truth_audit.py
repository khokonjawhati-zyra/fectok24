import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def truth_audit():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. INTERNAL FILE AUDIT (Container Side) ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway ls -R /usr/share/nginx/html/")
    print(stdout.read().decode())
    
    print("\n--- 3. NGINX FULL CONFIG DUMP (Reality Check) ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway nginx -T")
    print(stdout.read().decode())
    
    print("\n--- 4. GATEWAY ERROR LOGS ---")
    stdin, stdout, stderr = ssh.exec_command("docker logs --tail 50 sovereign_v15_gateway")
    print(stderr.read().decode())
    
    ssh.close()
    print("\n--- AUDIT COMPLETE ---")

if __name__ == "__main__":
    truth_audit()

