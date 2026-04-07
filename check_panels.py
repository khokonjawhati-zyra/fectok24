import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_panels_content():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. ADMIN FOLDER CONTENT AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway grep -i '<title>' /usr/share/nginx/html/admin/index.html")
    print("Admin Title Tag:", stdout.read().decode())
    
    print("\n--- 3. USER FOLDER CONTENT AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway grep -i '<title>' /usr/share/nginx/html/user/index.html")
    print("User Title Tag:", stdout.read().decode())

    print("\n--- 4. CORRECTING PATHS & RE-INJECTING ADMIN PANEL ---")
    # Ensuring Admin Panel files are correctly placed from the host's source
    ssh.exec_command("docker exec sovereign_v15_gateway rm -rf /usr/share/nginx/html/admin/*")
    ssh.exec_command("docker cp /root/sovereign_v15/webadmin_panel/. sovereign_v15_gateway:/usr/share/nginx/html/admin/")
    
    # Reloading Nginx to be 100% sure
    ssh.exec_command("docker exec sovereign_v15_gateway nginx -s reload")
    
    ssh.close()
    print("\n--- MISSION RE-IGNITED: ADMIN PANEL SHOULD BE LIVE ---")

if __name__ == "__main__":
    check_panels_content()

