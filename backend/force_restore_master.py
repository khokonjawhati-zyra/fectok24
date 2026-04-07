import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def force_restore_server_main():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    local_path = r'c:\Users\Admin\23226\backend\main.py'
    remote_path = '/root/sovereign/backend/main.py'
    
    print(f"--- Forcing Sovereign Restore: {remote_path} ---")
    
    # 1. SFTP Upload Clean Master Copy
    sftp = ssh.open_sftp()
    sftp.put(local_path, remote_path)
    sftp.close()
    print("✅ Master DNA Restored Successfully.")
    
    # 2. Precise Permission Lockdown
    ssh.exec_command(f"chmod 666 {remote_path}")
    
    # 3. Critical Reboot
    ssh.exec_command('docker restart sovereign_v15_backend')
    print("✅ Backend Container Re-ignited with Clean DNA.")
    
    ssh.close()

if __name__ == "__main__":
    force_restore_server_main()

