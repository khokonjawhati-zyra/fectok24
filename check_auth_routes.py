import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_login_routes():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Check for login/register/auth routes
    print("--- Searching for login/register/auth routes in main.py ---")
    stdin, stdout, stderr = ssh.exec_command('grep -E "/login|/register|/auth" /opt/sovereign/core/backend/main.py')
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_login_routes()

