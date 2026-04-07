import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_access_and_logs():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. CHECKING HOST DIRECTORIES ---")
    stdin, stdout, stderr = ssh.exec_command("ls -F /root/sovereign_v15/webuser_panel /root/sovereign_v15/webadmin_panel")
    print("Host Files:\n", stdout.read().decode())
    print("Errors (if any):\n", stderr.read().decode())
    
    print("\n--- 3. CHECKING CONTAINER MOUNTS ---")
    stdin, stdout, stderr = ssh.exec_command("docker inspect sovereign_v15_gateway --format='{{range .Mounts}}{{.Source}} -> {{.Destination}}{{end}}'")
    print("Container Mounts:\n", stdout.read().decode())

    print("\n--- 4. CHECKING NGINX LOGS ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway tail -n 20 /var/log/nginx/error.log")
    print("Nginx Error Logs:\n", stdout.read().decode())
    
    print("\n--- 5. CHECKING INTERNAL FILE EXISTENCE ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway ls -l /usr/share/nginx/html/admin_vault/index.html")
    print("Internal Admin HTML:\n", stdout.read().decode())
    
    ssh.close()
    print("\n--- AUDIT COMPLETE ---")

if __name__ == "__main__":
    check_access_and_logs()

