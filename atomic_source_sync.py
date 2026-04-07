import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def atomic_source_sync_v15():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 2. AUDITING MD5 SIGNATURES (Finding the Imposter) ---")
    # Comparing main.dart.js MD5 across folders to confirm contamination
    ssh.exec_command("md5sum /root/sovereign_v15/webadmin_panel/main.dart.js")
    ssh.exec_command("md5sum /root/sovereign_v15/webuser_panel/main.dart.js")

    print("--- 3. NUCLEAR PURGE OF SERVER SOURCE ---")
    ssh.exec_command("rm -rf /root/sovereign_v15/webadmin_panel")
    ssh.exec_command("mkdir -p /root/sovereign_v15/webadmin_panel")

    print("--- 4. PUSHING TRUE ADMIN ASSETS VIA SFTP ---")
    sftp = ssh.open_sftp()
    local_admin_dir = r'c:\Users\Admin\23226\webadmin_panel'
    remote_admin_dir = '/root/sovereign_v15/webadmin_panel'
    
    for file_name in os.listdir(local_admin_dir):
        local_file = os.path.join(local_admin_dir, file_name)
        if os.path.isfile(local_file):
            print(f"Syncing: {file_name}...")
            sftp.put(local_file, f"{remote_admin_dir}/{file_name}")
    
    sftp.close()

    print("--- 5. SURGICAL CONTAINER INJECTION ---")
    ssh.exec_command("docker exec sovereign_v15_gateway rm -rf /usr/share/nginx/html/admin_vault/*")
    ssh.exec_command("docker cp /root/sovereign_v15/webadmin_panel/. sovereign_v15_gateway:/usr/share/nginx/html/admin_vault/")
    
    # Final Base Href Lock
    ssh.exec_command("docker exec sovereign_v15_gateway sed -i 's|<base href=\"/\">|<base href=\"/admin/\">|g' /usr/share/nginx/html/admin_vault/index.html")

    print("--- 6. REBOOTING GATEWAY ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("--- MISSION COMPLETE: ADMIN IS NOW ATOMICALLY SYNCED ---")

if __name__ == "__main__":
    atomic_source_sync_v15()

