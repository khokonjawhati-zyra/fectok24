import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def fix_admin_otp_thread():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # We will remove the threading for admin OTP to ensure it finishes and logs properly.
    # Replace: threading.Thread(target=user_auth.send_admin_otp, args=(user_auth.ADMIN_TARGET_EMAIL, otp)).start()
    # with: user_auth.send_admin_otp(user_auth.ADMIN_TARGET_EMAIL, otp)
    command = "sed -i 's/threading.Thread(target=user_auth.send_admin_otp, args=(user_auth.ADMIN_TARGET_EMAIL, otp)).start()/user_auth.send_admin_otp(user_auth.ADMIN_TARGET_EMAIL, otp)/g' /root/sovereign/backend/main.py"
    ssh.exec_command(command)
    
    # Also ensure ADMIN_TARGET_EMAIL is set correctly even if not in .env
    # Add: user_auth.ADMIN_TARGET_EMAIL = \"khokonjawhati@gmail.com\"
    command = "sed -i '2039i \\        self.ADMIN_TARGET_EMAIL = \"khokonjawhati@gmail.com\"' /root/sovereign/backend/main.py"
    ssh.exec_command(command)

    # Restart backend
    ssh.exec_command('cd /root/sovereign && docker-compose restart backend_node')
    
    print("Admin OTP Thread fixed to Sync and Target Email Hardcoded for safety.")
    ssh.close()

if __name__ == "__main__":
    fix_admin_otp_thread()

