import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
LOCAL_PATH = r'c:\Users\Admin\23226\backend\main.py'
REMOTE_PATH = '/root/sovereign_v15/backend/main.py'

def upload_and_restart():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Direct SFTP Upload to bypass git and sed failures
    print("--- 1. UPLOADING FIXED main.py VIA SFTP ---")
    sftp = ssh.open_sftp()
    sftp.put(LOCAL_PATH, REMOTE_PATH)
    sftp.close()
    
    # 2. Re-Ignite backend
    print("--- 2. REBUILDING & RESTARTING BACKEND ---")
    # We rebuild to ensure the Dockerfile directory fix is also there
    ignite_cmd = "cd /root/sovereign_v15 && docker compose up -d --build backend_node"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Wait for completion & print
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
            
    print("\n--- 3. FINAL STATUS PULSE ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    upload_and_restart()

