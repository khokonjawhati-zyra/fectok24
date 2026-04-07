import os

# 1. Read main.py from the remote
import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def apply_nuclear_auth_patch():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Read the file
    sftp = ssh.open_sftp()
    with sftp.open('/root/sovereign/backend/main.py', 'r') as f:
        content = f.read().decode('utf-8')
    sftp.close()
    
    # 2. Relax the admin_auth_init check
    # Original: if master_clean == user_auth.ADMIN_MASTER_KEY and pin_clean == user_auth.ADMIN_PIN and hwid == user_auth.ADMIN_HWID:
    # New: if master_clean == user_auth.ADMIN_MASTER_KEY and pin_clean == user_auth.ADMIN_PIN:
    old_check = 'if master_clean == user_auth.ADMIN_MASTER_KEY and pin_clean == user_auth.ADMIN_PIN and hwid == user_auth.ADMIN_HWID:'
    new_check = 'if master_clean == user_auth.ADMIN_MASTER_KEY and pin_clean == user_auth.ADMIN_PIN:'
    
    if old_check in content:
        content = content.replace(old_check, new_check)
        print("Patched admin_auth_init: Removed HWID restriction.")
    else:
        print("Warning: Expected check not found. Searching for similar patterns...")
        # Check if it was already patched or looks slightly different
        if 'if master_clean == user_auth.ADMIN_MASTER_KEY and pin_clean == user_auth.ADMIN_PIN' in content:
             print("Check already relaxed or pattern slightly different.")
        
    # 3. Write it back
    sftp = ssh.open_sftp()
    with sftp.open('/root/sovereign/backend/main.py', 'w') as f:
        f.write(content)
    sftp.close()
    
    # 4. Restart backend
    print("Restarting backend...")
    ssh.exec_command('docker restart sovereign_v15_backend')
    
    ssh.close()

if __name__ == "__main__":
    apply_nuclear_auth_patch()

