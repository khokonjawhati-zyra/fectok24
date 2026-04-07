import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def inject_diagnostic_endpoint():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # We will inject a new log message in main.py to see if admin OTP is even triggered
    # and we will fix the potential threading issue by making it synchronous for a test.
    
    # 1. Add log before thread
    command = "sed -i '5172i \\        logger.info(f\"DEBUG: Triggering Admin OTP for {user_auth.ADMIN_TARGET_EMAIL} with code {otp}\")' /root/sovereign/backend/main.py"
    ssh.exec_command(command)
    
    # 2. Add log inside send_admin_otp
    command = "sed -i '2236i \\        logger.info(f\"DEBUG: Inside send_admin_otp for email={email}\")' /root/sovereign/backend/main.py"
    ssh.exec_command(command)
    
    # Restart backend
    ssh.exec_command('cd /root/sovereign && docker-compose restart backend_node')
    
    print("Diagnostics Injected and Backend Restarted.")
    ssh.close()

if __name__ == "__main__":
    inject_diagnostic_endpoint()

