import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def upload_directory(sftp, local_dir, remote_dir):
    """Recursively upload a directory via SFTP."""
    for item in os.listdir(local_dir):
        local_path = os.path.join(local_dir, item)
        remote_path = os.path.join(remote_dir, item).replace('\\', '/')
        
        if os.path.isdir(local_path):
            try:
                sftp.mkdir(remote_path)
            except:
                pass # Directory might already exist
            upload_directory(sftp, local_path, remote_path)
        else:
            print(f"Uploading {local_path} -> {remote_path}...")
            sftp.put(local_path, remote_path)

def main():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS)
    sftp = ssh.open_sftp()
    
    # 1. Upload Panels
    panels = [
        (r'c:\Users\Admin\23226\webadmin_panel', '/root/sovereign_v15/webadmin_panel'),
        (r'c:\Users\Admin\23226\webuser_panel', '/root/sovereign_v15/webuser_panel')
    ]
    
    for local, remote in panels:
        print(f"--- SYNCING {os.path.basename(local)} ---")
        try:
            sftp.mkdir(remote)
        except:
            pass
        upload_directory(sftp, local, remote)
        
    # 2. Upload Nginx Config
    print("--- SYNCING NGINX CONFIG ---")
    sftp.put(r'c:\Users\Admin\23226\nginx.conf', '/root/sovereign_v15/nginx.conf')
    
    sftp.close()
    
    # 3. Final Rebirth
    print("--- TRIGGERING GATEWAY REBIRTH ---")
    ssh.exec_command('cd /root/sovereign_v15 && docker compose restart stream_gateway')
    ssh.close()
    print("--- PAYLOAD SYNC COMPLETE: SYSTEM IS LIVE ---")

if __name__ == "__main__":
    main()

