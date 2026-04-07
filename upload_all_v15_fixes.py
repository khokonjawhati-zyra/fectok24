import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

FIXES = [
    (r'c:\Users\Admin\23226\backend\main.py', '/root/sovereign_v15/backend/main.py'),
    (r'c:\Users\Admin\23226\backend\Dockerfile', '/root/sovereign_v15/backend/Dockerfile'),
    (r'c:\Users\Admin\23226\sovereign_media_hub\uplink\Dockerfile', '/root/sovereign_v15/sovereign_media_hub/uplink/Dockerfile'),
    (r'c:\Users\Admin\23226\sovereign_media_hub\processor\Dockerfile', '/root/sovereign_v15/sovereign_media_hub/processor/Dockerfile'),
    (r'c:\Users\Admin\23226\docker-compose.yml', '/root/sovereign_v15/docker-compose.yml'),
    (r'c:\Users\Admin\23226\nginx.conf', '/root/sovereign_v15/nginx.conf')
]

def upload_all_fixes():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 1. UPLOADING ALL DNS, STATIC & CODE FIXES VIA SFTP ---")
    sftp = ssh.open_sftp()
    for local, remote in FIXES:
        print(f"Uploading {os.path.basename(local)} -> {remote}...")
        sftp.put(local, remote)
    sftp.close()
    
    ssh.close()
    print("Upload Complete.")

if __name__ == "__main__":
    upload_all_fixes()

