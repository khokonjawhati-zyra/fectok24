import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_backend_direct():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Try POST to login from localhost
    stdin, stdout, stderr = ssh.exec_command('curl -X POST -H "Content-Type: application/json" -d "{}" http://127.0.0.1:5000/login')
    print("--- POST /login (5000) ---")
    print(stdout.read().decode())
    
    # Try port 8108 too just in case
    stdin, stdout, stderr = ssh.exec_command('curl -X POST -H "Content-Type: application/json" -d "{}" http://127.0.0.1:8108/login')
    print("--- POST /login (8108) ---")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_backend_direct()

