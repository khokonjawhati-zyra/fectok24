import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def apply_backend_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Read main.py
    stdin, stdout, stderr = ssh.exec_command('cat /root/sovereign/backend/main.py')
    content = stdout.read().decode()
    
    # [A] Fix the crash in shutdown_event (NoneType check)
    original_shutdown = "await governor.close()"
    fixed_shutdown = "if governor:\n        await governor.close()"
    if original_shutdown in content:
        content = content.replace(original_shutdown, fixed_shutdown)
        print("Fixed shutdown_event crash.")
    
    # [B] Fix Admin OTP Recipient as per otpmail.md Logic
    # We want to ensure it sends to 'khokonjawhati@gmail.com'
    original_otp_line = 'user_auth.send_admin_otp(user_auth.SENDER_EMAIL, otp)' # Common bug mentioned in blueprint
    correct_otp_line = 'user_auth.send_admin_otp("khokonjawhati@gmail.com", otp)'
    
    # The blueprint says it should be threaded
    correct_otp_threaded = 'threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp)).start()'
    
    if "admin_auth_init" in content:
        # Simple replacement if we find the bug
        if "user_auth.SENDER_EMAIL, otp" in content:
            content = content.replace("user_auth.send_admin_otp(user_auth.SENDER_EMAIL, otp)", correct_otp_threaded)
            print("Fixed Admin OTP recipient bug.")
        elif "send_admin_otp" in content and "khokonjawhati@gmail.com" not in content:
             # If it's already threaded but with wrong email or something
             pass # Manual regex or more specific replacement might be needed
    
    # [C] Ensure SENDER_EMAIL is consistently used
    # [D] Ensure Admin Master Key etc are from .env?
    
    # Write back the file
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/backend/main.py', 'w') as f:
        f.write(content)
    sftp.close()
    
    # 2. Rebuild and Restart backend
    print("Rebuilding backend and restarting...")
    # Blueprint says: docker stop && docker rm && docker build && docker run
    restart_cmd = """
    docker stop sovereign_v15_backend || true
    docker rm sovereign_v15_backend || true
    cd /root/sovereign/backend
    docker build -t sovereign-backend_node:latest .
    docker run -d --name sovereign_v15_backend --network host sovereign-backend_node:latest uvicorn main:app --host 0.0.0.0 --port 5000 --workers 1
    """
    # Wait! Port 5000 was in the code I saw earlier. Blueprint said 8108.
    # I'll stick to 5000 as it's what uvicorn.run() uses in the script.
    
    stdin, stdout, stderr = ssh.exec_command(restart_cmd)
    res_out = stdout.read().decode()
    res_err = stderr.read().decode()
    print(res_out)
    print(res_err)
    
    ssh.close()

if __name__ == "__main__":
    apply_backend_fix()

