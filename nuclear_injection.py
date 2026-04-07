import paramiko
import os
import subprocess

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def nuclear_injection():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # Ensure directories exist inside container via shell
    print("--- 2. PREPARING CONTAINER PATHS ---")
    ssh.exec_command("docker exec sovereign_v15_gateway mkdir -p /usr/share/nginx/html/admin /usr/share/nginx/html/user")
    
    # Sync folders to host first (if not already there)
    print("--- 3. SYNCING PANELS TO HOST VAULT ---")
    # Using the existing upload_payload_v15.py logic but simplified
    sftp = ssh.open_sftp()
    
    def upload_dir_recursive(local, remote):
        for item in os.listdir(local):
            l_path = os.path.join(local, item)
            r_path = os.path.join(remote, item).replace('\\', '/')
            if os.path.isdir(l_path):
                try: sftp.mkdir(r_path)
                except: pass
                upload_dir_recursive(l_path, r_path)
            else:
                sftp.put(l_path, r_path)

    upload_dir_recursive(r'c:\Users\Admin\23226\webadmin_panel', '/root/sovereign_v15/webadmin_panel')
    upload_dir_recursive(r'c:\Users\Admin\23226\webuser_panel', '/root/sovereign_v15/webuser_panel')
    sftp.put(r'c:\Users\Admin\23226\nginx.conf', '/root/sovereign_v15/nginx.conf')
    sftp.close()
    
    print("--- 4. NUCLEAR INJECTION (Direct Docker CP) ---")
    # This ensures files are INSIDE the container regardless of volume mounts
    ssh.exec_command("docker cp /root/sovereign_v15/webadmin_panel/. sovereign_v15_gateway:/usr/share/nginx/html/admin/")
    ssh.exec_command("docker cp /root/sovereign_v15/webuser_panel/. sovereign_v15_gateway:/usr/share/nginx/html/user/")
    
    print("--- 5. RESTARTING GATEWAY ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    print("--- 6. VERIFYING INTEGRITY ---")
    import time
    time.sleep(5)
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/admin/")
    print(stdout.read().decode())
    
    ssh.close()
    print("--- MISSION COMPLETE: SYSTEM IS LIVE BY FORCE ---")

if __name__ == "__main__":
    nuclear_injection()

