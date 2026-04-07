import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_remote_content():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Look for the OLD string in the backend file
    stdin, stdout, stderr = ssh.exec_command('grep -c "Unauthorized Handshake Attempt" /root/sovereign/backend/main.py')
    print(f"Count of OLD string: {stdout.read().decode().strip()}")
    
    # 2. Look for the NEW string in the backend file
    stdin, stdout, stderr = ssh.exec_command('grep -c "PULSE_AUTHORISED" /root/sovereign/backend/main.py')
    print(f"Count of NEW string: {stdout.read().decode().strip()}")
    
    # 3. Print the function
    stdin, stdout, stderr = ssh.exec_command('sed -n "/def admin_auth_init/,/admin_auth_verify/p" /root/sovereign/backend/main.py')
    print("\n--- CODE CONTENT ---")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_remote_content()

