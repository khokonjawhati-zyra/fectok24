import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
LOCAL_MAIN = r'c:\Users\Admin\23226\backend\main.py'
LOCAL_DOCKER = r'c:\Users\Admin\23226\backend\Dockerfile'
REMOTE_MAIN = '/root/sovereign_v15/backend/main.py'
REMOTE_DOCKER = '/root/sovereign_v15/backend/Dockerfile'

def upload_fixes():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Direct SFTP Upload to bypass git and sed failures
    print("--- 1. UPLOADING FIXED FILES VIA SFTP ---")
    sftp = ssh.open_sftp()
    print(f"Uploading {LOCAL_MAIN}...")
    sftp.put(LOCAL_MAIN, REMOTE_MAIN)
    print(f"Uploading {LOCAL_DOCKER}...")
    sftp.put(LOCAL_DOCKER, REMOTE_DOCKER)
    sftp.close()
    
    ssh.close()
    print("Upload Complete.")

if __name__ == "__main__":
    upload_fixes()

