import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def patch_server_main():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Read main.py from Server
    _, out, _ = ssh.exec_command('cat /root/sovereign/backend/main.py')
    content = out.read().decode('utf-8')
    
    # 2. String DNA Surgery
    target = '["/admin_auth_init", "/admin_auth_verify", "/login", "/forgot_password", "/reset_password", "/register"]'
    replacement = '["/admin_auth_init", "/admin_auth_verify", "/login", "/forgot_password", "/reset_password", "/register", "/verify_token", "/reset_pulse"]'
    
    if target in content:
        new_content = content.replace(target, replacement)
        
        # 3. Write back surgically
        sftp = ssh.open_sftp()
        with sftp.file('/root/sovereign/backend/main.py', 'w') as f:
            f.write(new_content)
        sftp.close()
        print('✅ DNA Patch applied successfully.')
        
        # 4. Critical Reboot
        ssh.exec_command('docker restart sovereign_v15_backend')
        print('✅ Backend Container Rebooted (Re-ignited).')
    else:
        print('❌ Target DNA not found! Check main.py version.')
        
    ssh.close()

if __name__ == "__main__":
    patch_server_main()

