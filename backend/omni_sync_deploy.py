import paramiko
import os
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

LOCAL_DIR = r"c:\Users\Admin\23226\admin_panel\build\web"
REMOTE_DIR = "/root/sovereign/webadmin_panel"

def upload_folder(ssh_client, local_path, remote_path):
    sftp = ssh_client.open_sftp()
    
    # Try creating remote dir
    try:
        sftp.mkdir(remote_path)
    except:
        pass

    for root, dirs, files in os.walk(local_path):
        # Create dirs
        for d in dirs:
            local_dir = os.path.join(root, d)
            rel_path = os.path.relpath(local_dir, local_path).replace("\\", "/")
            remote_full_path = os.path.join(remote_path, rel_path).replace("\\", "/")
            try:
                sftp.mkdir(remote_full_path)
            except:
                pass
        
        # Upload files
        for f in files:
            local_file = os.path.join(root, f)
            rel_path = os.path.relpath(local_file, local_path).replace("\\", "/")
            remote_full_path = os.path.join(remote_path, rel_path).replace("\\", "/")
            print(f"Uploading {rel_path}...")
            sftp.put(local_file, remote_full_path)
            
    sftp.close()

def final_deploy():
    if not os.path.exists(LOCAL_DIR):
        print(f"❌ Build folder {LOCAL_DIR} not found yet!")
        return

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- 🚀 PHASE 1: Purging Remote Folder ---")
    ssh.exec_command(f"rm -rf {REMOTE_DIR}/*")
    
    print("--- 🚀 PHASE 2: Uploading Local Build ---")
    upload_folder(ssh, LOCAL_DIR, REMOTE_DIR)
    
    print("--- 🚀 PHASE 3: Restarting Sovereign Gateway ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    print("--- ✅ DEPLOYMENT COMPLETE ---")
    ssh.close()

if __name__ == "__main__":
    final_deploy()

