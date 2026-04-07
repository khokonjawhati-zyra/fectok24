import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_backend_routes():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Check if /api/v15/auth/status exists in main.py
    print("--- Searching for /api/v15/auth/status in main.py ---")
    stdin, stdout, stderr = ssh.exec_command('grep "/api/v15/auth/status" /opt/sovereign/core/backend/main.py')
    print(stdout.read().decode())
    
    # Check if there is any /api/v15/ route
    print("--- Listing /api/v15/ routes ---")
    stdin, stdout, stderr = ssh.exec_command('grep "@app." /opt/sovereign/core/backend/main.py | grep "/api/v15/"')
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_backend_routes()

